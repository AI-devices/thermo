import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/notifier.dart';
import 'package:thermo/components/settings.dart';

class ApiBluetooth {
  static ApiBluetooth? _instance;
  
  static bool _offerBluetoothOn = false;

  static bool statusSensor = false;
  static bool statusBluetooth = false;
  static VoidCallback? bluetoothStatusChanged;
  static final _controllerTemperature = StreamController<double>.broadcast();
  static Stream<double> get temperatureStream => _controllerTemperature.stream;
  static final _controllerStatusSensor = StreamController<bool>.broadcast();
  static Stream<bool> get statusSensorStream => _controllerStatusSensor.stream;

  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _characteristicBattery;

  factory ApiBluetooth() {
    return _instance ??= ApiBluetooth._();
  }

  ApiBluetooth._() {
    _init();
  }

  Future<void> _init() async {
    _scanDevices();
    
    FlutterBluePlus.adapterState.listen((state) async {
      log(state.toString(), name: 'Bluetooth status');

      if (state == BluetoothAdapterState.turningOff) {
        statusBluetooth = false;
        await _dissconnectToSensor(); //! на 13 ОС Андроид, стрим по состоянию датчика не отлавливает дисконнект в случае отключения bluetooth
      }

      if (state == BluetoothAdapterState.off) {
        if (statusBluetooth != false) statusBluetooth = false;
        bluetoothStatusChanged?.call();
        Notifier.snackBar(notify: Notify.bluetoothDissconected);
      }

      if (state == BluetoothAdapterState.on) {
        statusBluetooth = true;
        bluetoothStatusChanged?.call();
        if (_device == null) {
          await _startScan();
        } else {
          _listenConnect();
        }
      } 

      if (Platform.isAndroid && ApiBluetooth._offerBluetoothOn == false) {
        ApiBluetooth._offerBluetoothOn = true;
        try {
          await FlutterBluePlus.turnOn();
        } catch (error) {
          log(error.toString(), name: 'FlutterBluePlus.turnOn()');
        }
      }
    });
  }

  Future<void> _startScan() async {
    try {
      await FlutterBluePlus.startScan();

      Future.delayed(const Duration(seconds: 2), () { //во future завернул, чтобы сперва сканирование отработало
        if (_device == null) {
          Notifier.snackBar(notify: Notify.sensorNotFound);
          _controllerStatusSensor.add(false);
        }
      });
    } catch (error) {
      //т.к. запрос локации стал не обязателен с ОС >=12, то делать через проверку прав смысла немного 
      log(error.toString(), name: 'startScan FAIL');
      if (error.toString().contains('requires android.permission.ACCESS_FINE_LOCATION')) {
        Notifier.snackBar(notify: Notify.locationIsRequred);
      }
    }
  }


  static Future<bool> isSupported() async {
    final isSupported = await FlutterBluePlus.isSupported;
    if (isSupported) return true;
    Notifier.snackBar(notify: Notify.bluetoothIsNotSupported);
    return false;
  }

  Future<void> _scanDevices() async {
    FlutterBluePlus.scanResults.listen(
      (results) async {
        for (ScanResult r in results) {
          if (r.device.platformName.toLowerCase() == Settings.nameDevice) {
            FlutterBluePlus.stopScan();
            log(r.toString(), name: 'sensor found');
            _device = BluetoothDevice(remoteId: r.device.remoteId);
            _listenConnect();
          }
        }
      },
      //onError(e) => print(e);
    );
  }

  Future<void> _listenConnect() async {
    await _connectToSensor();

    _device!.connectionState.listen((BluetoothConnectionState state) async {
      log(state.toString(), name: 'Sensor status');
      if (state == BluetoothConnectionState.disconnected) {
        await _dissconnectToSensor();

        await _connectToSensor();
      }

      if (state == BluetoothConnectionState.connected && statusBluetooth == true) {
        if (statusSensor == false) {
          statusSensor = true;
          _controllerStatusSensor.add(true);
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
        _controllerTemperature.add(Helper.parseTemperature(event));
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

  Future<void> _dissconnectToSensor() async {
    if (_device != null && statusSensor == true) {
      try {
        await _device!.disconnect();
      } catch (e) {
        log(e.toString(), name: 'device.disconnect()');
      }
      statusSensor = false;
      _controllerStatusSensor.add(false);
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