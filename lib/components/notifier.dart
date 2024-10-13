import 'package:flutter/material.dart';
import 'package:thermo/components/adaptive.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';
import 'package:thermo/main.dart';

enum Notify {
  bluetoothIsNotSupported,
  bluetoothDissconected,
  sensorNotFound,
  sensorDissconnected,
  checkpointReached,
}

abstract class Notifier {
  static void snackBar({required Notify notify, String? text}) {
    switch (notify) {
      case Notify.bluetoothIsNotSupported :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: Lang.text('Данный девайс не поддерживает Bluetooth'),
          icon: const Icon(Icons.bluetooth_disabled, color: Colors.red));
        break;
      case Notify.bluetoothDissconected :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: Lang.text('Нет соединения с Bluetooth'),
          icon: const Icon(Icons.bluetooth_disabled, color: Colors.red));
        break;
      case Notify.sensorNotFound :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: Lang.text('Термодатчик не обнаружен. Убедитесь, что он включен'),
          icon: const Icon(Icons.close, color: Colors.red));
        break;
      case Notify.sensorDissconnected :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: Lang.text('Потеряно соединение с термодатчиком'),
          icon: const Icon(Icons.thermostat, color: Colors.red));
        break;
      case Notify.checkpointReached :
        Helper.viewSnackBar(context: navigatorKey.currentState!.context,
          text: text ?? Lang.text('Пройдена контрольная точка'),
          icon: const Icon(Icons.control_point, color: AppStyle.mainColor));
        break;
    }
  }

  static Icon getNotifyIcon({required String type, required BuildContext context, Color? color}) {
    switch (type) {
      case Settings.typeRing :
        return Icon(Icons.volume_up_outlined, size: Adaptive.icon(30, context), color: color ?? Colors.black);
      case Settings.typeVibration :
        return Icon(Icons.vibration, size: Adaptive.icon(30, context), color: color ?? Colors.black);
      case Settings.typeNone :
      default :
        return Icon(Icons.clear, size: Adaptive.icon(30, context), color: color ?? Colors.black);
    }
  }
}