import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth_v1.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth_v2.dart';
import 'package:thermo/components/notifier.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/main.dart';
import 'package:thermo/widgets/assets.dart';

enum ApiBluetoothVersion {
  unknown,
  version1,
  version2,
}

class ApiBluetooth with ApiBluetoothV1, ApiBluetoothV2 {
  static ApiBluetooth? _instance;

  final _player = AudioPlayer();

  static late ApiBluetoothVersion version;
  
  static bool _offerBluetoothOn = false;

  static bool statusSensor = false;
  static bool statusBluetooth = false;
  static VoidCallback? bluetoothStatusChanged;
  static final controllerTemperature = StreamController<double>.broadcast();
  static Stream<double> get temperatureStream => controllerTemperature.stream;
  static final controllerStatusSensor = StreamController<bool>.broadcast();
  static Stream<bool> get statusSensorStream => controllerStatusSensor.stream;

  factory ApiBluetooth() {
    version = ApiBluetoothVersion.unknown;
    return _instance ??= ApiBluetooth._();
  }

  ApiBluetooth._() {
    FlutterBluePlus.setLogLevel(LogLevel.error, color: true);
    _init();
  }

  Future<void> _init() async {
    _scanDevices();
    
    FlutterBluePlus.adapterState.listen((state) async {
      log(state.toString(), name: 'Bluetooth status');

      if (state == BluetoothAdapterState.turningOff) {
        statusBluetooth = false;
        await dissconnect();
      }

      if (state == BluetoothAdapterState.off) {
        version = ApiBluetoothVersion.unknown;
        if (statusBluetooth != false) statusBluetooth = false;
        bluetoothStatusChanged?.call();
        Notifier.snackBar(notify: Notify.bluetoothDissconected);
      }

      if (state == BluetoothAdapterState.on) {
        statusBluetooth = true;
        bluetoothStatusChanged?.call();
        await _startScan();
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
        if (version == ApiBluetoothVersion.unknown) {
          Notifier.snackBar(notify: Notify.sensorNotFound);
          controllerStatusSensor.add(false);
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

  Future<void> _scanDevices() async {
    FlutterBluePlus.scanResults.listen(
      (results) async {
        for (ScanResult r in results) {
          if (r.device.platformName.toLowerCase() == ApiBluetoothV1.nameDevice) readDataV1(r);
          if (r.device.platformName.startsWith(ApiBluetoothV2.prefixDevice)) readDataV2(r);
        }
      },
    );
  }

  Future<void> dissconnect() async {
    if (version == ApiBluetoothVersion.version1) dissconnectToSensorV1();
    if (version == ApiBluetoothVersion.version2) dissconnectToSensorV2();
    version = ApiBluetoothVersion.unknown;
  }

  static Future<int?> getBatteryCharge() async {
    if (version == ApiBluetoothVersion.version1) return ApiBluetoothV1.getBatteryCharge();
    if (version == ApiBluetoothVersion.version2) return ApiBluetoothV2.batteryCharge;
    return null;
  }

  static Future<bool> isSupported() async {
    final isSupported = await FlutterBluePlus.isSupported;
    if (isSupported) return true;
    Notifier.snackBar(notify: Notify.bluetoothIsNotSupported);
    return false;
  }

  void alarmSensorDissconnected() {
    if (Settings.alarmSensorDissconnected == false) return;
    prevAlarmSensorDissconnectedClose();

    _player.play(AssetSource('../${AppAssets.alarmAudioLong}'));

    showDialog<dynamic>(
      context: navigatorKey.currentState!.context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            title: const Text('Предупреждение'),
            content: const Text('Потеряно соединение с термодатчиком'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10) 
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _player.stop();
                }, 
                child: const Text('OK'))
            ],
          )
        );
      },
    );
  }

  void prevAlarmSensorDissconnectedClose() {
    if (Settings.alarmSensorDissconnected == false) return;
    if (Navigator.of(navigatorKey.currentState!.context).canPop()) {
      Navigator.of(navigatorKey.currentState!.context).pop();
      _player.stop();
    }
  }
}