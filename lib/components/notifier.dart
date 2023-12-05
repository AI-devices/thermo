import 'package:flutter/material.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/main.dart';

enum Notify {
  bluetoothIsNotSupported,
  bluetoothDissconected,
  locationIsRequred,
  sensorNotFound,
  sensorConnected,
  sensorDissconnected,
  checkpointReached,
}

abstract class Notifier {
  static void snackBar({required Notify notify, String? text}) {
    switch (notify) {
      case Notify.bluetoothIsNotSupported :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: 'Данный девайс не поддерживает Bluetooth',
          icon: const Icon(Icons.bluetooth_disabled, color: Colors.red));
        break;
      case Notify.bluetoothDissconected :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: 'Нет соединения с Bluetooth',
          icon: const Icon(Icons.bluetooth_disabled, color: Colors.red));
        break;
      case Notify.locationIsRequred :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: 'Разрешение к метоположению устройства не получено. Подключиться к датчику невозможно',
          icon: const Icon(Icons.close, color: Colors.red),
          duration: 6);
        break;
      case Notify.sensorNotFound :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: 'Термодатчик не обнаружен. Убедитесь, что он включен',
          icon: const Icon(Icons.close, color: Colors.red));
        break;
      case Notify.sensorConnected :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: 'Подключение к термодатчику установлено');
        break;
      case Notify.sensorDissconnected :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: 'Потеряно соединение с термодатчиком',
          icon: const Icon(Icons.thermostat, color: Colors.red));
        break;
      case Notify.checkpointReached :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: text ?? 'Пройдена контрольная точка',
          icon: const Icon(Icons.control_point, color: Colors.green));
        break;
    }
  }

  static Icon getNotifyIcon({required String type, double? size, Color? color}) {
    switch (type) {
      case Settings.typeRing :
        return Icon(Icons.phonelink_ring, size: size ?? 24, color: color ?? Colors.black);
      case Settings.typeVibration :
        return Icon(Icons.vibration, size: size ?? 24, color: color ?? Colors.black);
      case Settings.typeNone :
      default :
        return Icon(Icons.clear, size: size ?? 24, color: color ?? Colors.black);
    }
  }
}