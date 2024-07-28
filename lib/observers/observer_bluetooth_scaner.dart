import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/notifier.dart';

class ObserverBluetoothScaner {
  static ObserverBluetoothScaner? _instance;

  final ApiBluetooth _apiBluetooth = ApiBluetooth();
  static bool _offerBluetoothOn = false;
  static VoidCallback? bluetoothStatusChanged;

  factory ObserverBluetoothScaner() {
    return _instance ??= ObserverBluetoothScaner._();
  }

  ObserverBluetoothScaner._() {
    _init();
  }

  Future<void> _init() async {
    FlutterBluePlus.adapterState.listen((state) async {
      log(state.toString(), name: 'Bluetooth status');

      if (state == BluetoothAdapterState.turningOff) {
        ApiBluetooth.statusBluetooth = false;
        await _apiBluetooth.dissconnect(); //! на 13 ОС Андроид, стрим по состоянию датчика не отлавливает дисконнект в случае отключения bluetooth
      }

      if (state == BluetoothAdapterState.off) {
        ApiBluetooth.version = ApiBluetoothVersion.unknown;
        if (ApiBluetooth.statusBluetooth != false) ApiBluetooth.statusBluetooth = false;
        bluetoothStatusChanged?.call();
        Notifier.snackBar(notify: Notify.bluetoothDissconected);
      }

      if (state == BluetoothAdapterState.on) {
        ApiBluetooth.statusBluetooth = true;
        bluetoothStatusChanged?.call();
        await _apiBluetooth.startScan();
      } 

      if (Platform.isAndroid && _offerBluetoothOn == false) {
        _offerBluetoothOn = true;
        try {
          await FlutterBluePlus.turnOn();
        } catch (error) {
          log(error.toString(), name: 'FlutterBluePlus.turnOn()');
        }
      }
    });
  }
}