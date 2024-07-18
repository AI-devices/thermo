import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/notifier.dart';
import 'package:thermo/components/settings.dart';

mixin ApiBluetoothV1 {
  static const nameDevice = 'temperature sensor';

  static BluetoothDevice? _device; 
  static BluetoothCharacteristic? _characteristicBattery;

  Future<void> listenConnect({required DeviceIdentifier deviceId}) async {
    _device = BluetoothDevice(remoteId: deviceId);
    await _connectToSensor();

    _device!.connectionState.listen((BluetoothConnectionState state) async {
      log(state.toString(), name: 'Sensor status');
      if (state == BluetoothConnectionState.disconnected) {
        await dissconnectToSensorV1();
        await _connectToSensor();
      }

      if (state == BluetoothConnectionState.connected && ApiBluetooth.statusBluetooth == true) {
        if (ApiBluetooth.statusSensor == false) {
          ApiBluetooth.statusSensor = true;
          ApiBluetooth.controllerStatusSensor.add(true);
          (this as ApiBluetooth).prevAlarmSensorDissconnectedClose();
          Notifier.snackBar(notify: Notify.sensorConnected);
        }
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
      characteristicTemperature.onValueReceived.listen((event) {
        ApiBluetooth.controllerTemperature.add(Helper.parseTemperature(event));
      });
    } catch (err) {
      log(err.toString(), name: 'onValueReceived Temperature');
    }
  }

  Future<void> _connectToSensor() async {
    try {
      await _device!.connect();
      _read();
    } catch (e) {
      /**
       * FlutterBluePlusException: connect: (code: 133) ANDROID_SPECIFIC_ERROR - если датчик выключен
       * PlatformException(connect, device.connectGatt returned null, null, null) - если bluetooth отключился
       */
      log(e.toString(), name: 'device.connect()');
    }
  }

  Future<void> dissconnectToSensorV1() async {
    if (_device != null && ApiBluetooth.statusSensor == true) {
      try {
        //! на 13 ОС Андроид, стрим по состоянию датчика не отлавливает дисконнект в случае отключения bluetooth
        await _device!.disconnect();
      } catch (e) {
        log(e.toString(), name: 'device.disconnect()');
      }
      ApiBluetooth.statusSensor = false;
      ApiBluetooth.controllerStatusSensor.add(false);
      (this as ApiBluetooth).alarmSensorDissconnected();
    }
  }

  static Future<int?> getBatteryCharge() async {
    if (_characteristicBattery == null) return null;
    try {
      List<int> chargeBattery = await _characteristicBattery!.read();
      log(chargeBattery.toString(), name: 'chargeBattery');
      return chargeBattery[0];
    } catch (e) {
      log(e.toString(), name: 'getBatteryCharge()');
      return null;
    }
  }
}