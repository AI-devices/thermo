import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/main.dart';
import 'package:vibration/vibration.dart';

abstract class DevicePermissions {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<bool> checkPermissions() async {
    AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    log(androidInfo.version.release, name: 'version OS');

    _vibration();

    //final ignoreBatteryPermission = await DevicePermissions._getPermission(Permission.ignoreBatteryOptimizations);

    if (await ApiBluetooth.isSupported() == false) {
      // ignore: use_build_context_synchronously
      Helper.alert(context: navigatorKey.currentState!.context, content: 'Bluetooth не поддерживается устройством', title: 'Ошибка');
      return false;
    }

    return double.parse(androidInfo.version.release) < 12 ? _location() : _bluetooth();
  }

  static Future<bool> _bluetooth() async {
    final permission = await DevicePermissions._getPermission(Permission.bluetoothConnect);
    if (!permission.isGranted) {
      // ignore: use_build_context_synchronously
      Helper.alert(context: navigatorKey.currentState!.context, content: 'Доступ к bluetooth запрещен. Установить соединение с датчиком невозможно');
      return false;
    }
    return true;
  }

  static Future<bool> _location() async {
    bool locationIsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationIsEnabled) {
      // ignore: use_build_context_synchronously
      Helper.alert(context: navigatorKey.currentState!.context, content: 'Включите передачу локации. Без этого bluetooth работать не будет.');
      return false;
    }

    final permission = await DevicePermissions._getPermission(Permission.location);
    if (!permission.isGranted) {
      // ignore: use_build_context_synchronously
      Helper.alert(context: navigatorKey.currentState!.context, content: 'Доступ к локации запрещен. Без этого bluetooth работать не будет.');
      return false;
    }
    return true;
  }

  static Future<void> _vibration() async {
    Settings.vibrationIsSupported = await Vibration.hasVibrator() == true;
    log(Settings.vibrationIsSupported.toString(), name: 'vibrationIsSupported');
  }

  static Future<PermissionStatus> _getPermission(Permission typeApi) async {
    var permission = await typeApi.status;
    log(permission.toString(), name: typeApi.toString());
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      var permissionStatus = await typeApi.request();
      log(permissionStatus.toString(), name: 'new ${typeApi.toString()}');
      return permissionStatus;
    } else {
      return permission;
    }
  }
}