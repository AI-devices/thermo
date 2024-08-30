import 'dart:ui';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/observers/observer_app_lifecycle.dart';

class ObserverDeviceScaner {
  static ObserverDeviceScaner? _instance;

  final ApiBluetooth _apiBluetooth = ApiBluetooth();

  factory ObserverDeviceScaner() {
    return _instance ??= ObserverDeviceScaner._();
  }

  ObserverDeviceScaner._() {
    FlutterBluePlus.scanResults.listen(
      (results) {
        for (ScanResult r in results) {
          if (r.device.platformName.toLowerCase() == Settings.nameDeviceOldSensor) _apiBluetooth.readDataV1(r);
          if (r.device.platformName.startsWith(Settings.prefixDeviceNewSensor)) {
            if (!Settings.useOnlyV1 && (ApiBluetooth.version == ApiBluetoothVersion.version2 || ObserverAppLifecycle.state == AppLifecycleState.paused)) {
              _apiBluetooth.readDataV2(r);
            } else {
              _apiBluetooth.readDataV1(r);
            }
          }
        }
      },
    );
  }
}