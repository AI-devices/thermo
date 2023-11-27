import 'dart:ui';

abstract class Settings {
  static bool envDebug = false;
  static late int maxHoursForStat;
  static VoidCallback? maxHoursForStatChanged;

  static bool vibrationIsSupported = false;

  static const nameDevice = 'temperature sensor';
  static const uuidServiceTemperature = '0000181a-0000-1000-8000-00805f9b34fb';
  static const uuidCharacteristicTemperature = '00002a6e-0000-1000-8000-00805f9b34fb';
  static const uuidServiceBattery = '0000180f-0000-1000-8000-00805f9b34fb';
  static const uuidCharacteristicBattery = '00002a19-0000-1000-8000-00805f9b34fb';

  static const typeRing = 'ring';
  static const typeVibration = 'vibration';
  static const typeNone = 'none';
}