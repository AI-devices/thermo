import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth_v2.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/settings.dart';

mixin ApiBluetoothV1 {
  static const Map<int, String> connectionErrorCodes = {
    0   : 'SUCCESS', //срабатывает один раз при выключении датчика и отключения bluetooth
    133 : 'ANDROID_SPECIFIC_ERROR', //цикличная ошибка, срабатывает, когда пытаемся подключиться к выключенному датчику
  };

  static late BluetoothConnectionState _connectionState; 
  static BluetoothDevice? _device; 
  static BluetoothCharacteristic? _characteristicBattery;

  void readDataV1(ScanResult r) {
    if (ApiBluetooth.version == ApiBluetoothVersion.version2) return;

    if (r.device.platformName.toLowerCase() == Settings.nameDeviceOldSensor) ApiBluetooth.version = ApiBluetoothVersion.version1oldSensor;
    if (r.device.platformName.startsWith(Settings.prefixDeviceNewSensor)) ApiBluetooth.version = ApiBluetoothVersion.version1newSensor;
    
    FlutterBluePlus.stopScan();
    log(r.toString(), name: ApiBluetooth.version.toString());
    if (!Settings.remoteIds.contains(r.device.remoteId.toString())) Settings.remoteIds.add(r.device.remoteId.toString());

    //? т.к. новая версия не отдает сразу температуру, а только при изменении, то первый раз при подключении считываем с advertise
    if (ApiBluetooth.version == ApiBluetoothVersion.version1newSensor) {
      var result = ApiBluetoothV2.parseBytesFromAdvertise(r.advertisementData);
      if (result['temperature'] != null) ApiBluetooth.controllerTemperature.add(result['temperature']);
    }

    _listenConnect(deviceId: r.device.remoteId);
  }

  Future<void> _listenConnect({required DeviceIdentifier deviceId}) async {
    bool needListenConnectionState = _device == null;

    _device = BluetoothDevice(remoteId: deviceId); //даже, если _device уже есть, лучше обновить, допустим, после разрыва bluetooth
    await _connectToSensor();

    if (needListenConnectionState == false) return; //значит уже этот стрим запущен - выходим

    _device!.connectionState.listen((BluetoothConnectionState state) async {
      _connectionState = state;
      log(state.toString(), name: 'Sensor status');
      if (state == BluetoothConnectionState.disconnected && ApiBluetooth.version != ApiBluetoothVersion.version2) {
        log("error code: ${_device!.disconnectReason?.code} | error desc: ${_device!.disconnectReason?.description}");
        if (_device!.disconnectReason?.code != 133) dissconnectToSensorV1();
        await _connectToSensor();
      }

      if (state == BluetoothConnectionState.connected && ApiBluetooth.statusBluetooth == true) {
        await _read();
      }
    });
  }

  Future<void> _read() async {
    List<BluetoothService> allServices = await _device!.discoverServices();

    final serviceTemperature = allServices.firstWhere((e) => e.uuid.toString().toLowerCase() == Settings.uuidServiceTemperature);
    final characteristicTemperature = serviceTemperature.characteristics.firstWhere((e) => 
      e.uuid.toString().toLowerCase() == Settings.uuidCharacteristicTemperature);

    final serviceBattery = allServices.firstWhere((e) => e.uuid.toString().toLowerCase() == Settings.uuidServiceBattery);
    _characteristicBattery = serviceBattery.characteristics.firstWhere((e) => 
      e.uuid.toString().toLowerCase() == Settings.uuidCharacteristicBattery);  

    try {
      await characteristicTemperature.setNotifyValue(true);
      //! перенес именно сюда, т.к. на новых датчиках бывает большой лаг между тем как подключились к датчику и считали первую температуру с него
      //! по крайней мере при первом подключении
      connectNotify();

      final subscription = characteristicTemperature.onValueReceived.listen((event) {
        ApiBluetooth.controllerTemperature.add(Helper.parseTemperature(event));
      });
      _device!.cancelWhenDisconnected(subscription);
    } catch (err) {
      log(err.toString(), name: 'onValueReceived Temperature');
    }
  }

  Future<void> _connectToSensor() async {
    if (ApiBluetooth.version == ApiBluetoothVersion.version2) return;
    try {
      await _device!.connect();
    } catch (e) {
      /**
       * FlutterBluePlusException: connect: (code: 133) ANDROID_SPECIFIC_ERROR - если датчик выключен
       * PlatformException(connect, device.connectGatt returned null, null, null) - если bluetooth отключился
       */
      log(e.toString(), name: 'device.connect()');
    }
  }

  static Future<int?> getBatteryCharge() async {
    if (_characteristicBattery == null) return null;
    try {
      List<int> chargeBattery = await _characteristicBattery!.read();
      return chargeBattery[0];
    } catch (e) {
      log(e.toString(), name: 'getBatteryCharge()');
      return null;
    }
  }

  Future<void> dissconnectToSensorV1() async {
    //! пауза 20 сек, т.к. при переключении версий иногда проскакивают дисконнекты. 10-15 сек может не хватать, 20 вроде всегда хватает
    Future.delayed(const Duration(seconds: 20), () async {
      if (_connectionState == BluetoothConnectionState.connected) return;

      if (_device != null && ApiBluetooth.statusSensor == true) {
        try {
          await _device!.disconnect();
        } catch (e) {
          log(e.toString(), name: 'device.disconnect()');
        }

        ApiBluetooth.statusSensor = false;
        ApiBluetooth.controllerStatusSensor.add(false);
        (this as ApiBluetooth).alarmSensorDissconnected();
      }
    });
  }

  Future<void> switchOffV1() async {
    if (_device != null && ApiBluetooth.statusSensor == true) {
      try {
        await _device!.disconnect();
      } catch (_) {}
    }
  }

  void switchOnV1() {
    ApiBluetooth.version = ApiBluetoothVersion.version1newSensor;
    log('switch to ${ApiBluetooth.version}');
  }

  void connectNotify() {
    if (ApiBluetooth.statusSensor == false) {
      ApiBluetooth.statusSensor = true;
      ApiBluetooth.controllerStatusSensor.add(true);
      (this as ApiBluetooth).prevAlarmSensorDissconnectedClose();
      //Notifier.snackBar(notify: Notify.sensorConnected);
    }
  }
}