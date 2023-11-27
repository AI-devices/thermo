import 'dart:developer';
import 'package:thermo/components/settings.dart';
import 'package:vibration/vibration.dart';

class ApiVibration {
  static Future<void> isSupported() async {
    Settings.vibrationIsSupported = await Vibration.hasVibrator() == true;
    log(Settings.vibrationIsSupported.toString(), name: 'vibrationIsSupported');
  }
}