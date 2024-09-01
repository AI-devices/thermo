import 'dart:developer';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/widgets/assets.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart' as foundation;

abstract class Settings {
  static final _player = AudioPlayer();
  static final _dataProvider = DataProvider();

  static const useOnlyV1 = bool.fromEnvironment('use_only_v1', defaultValue: false);
  
  static bool envDebug = false;
  static late int maxHoursForChart;
  static VoidCallback? maxHoursForChartChanged;
  
  static late List<FlSpot> coordinatesChart;
  static setCoordinatesChart(List<FlSpot> coordinates) {
    coordinatesChart = coordinates;
    _dataProvider.saveCoordinates();
  }
  static late double scaleAxisX;
  static setScaleAxisX(double value) {
    scaleAxisX = value;
    _dataProvider.saveAxisX();
  }

  static late String notifyWhenTempDrops;
  static VoidCallback? notifyWhenTempDropsChanged;
  static late String notifyWhenTimerEnds;
  static late double calibrationSensor;
  static late bool hidePercentSpiritWidget;
  static VoidCallback? hidePercentSpiritWidgetChanged;
  static late Map<String, dynamic> alarmLowBatteryCharge;
  static late bool wakelock;
  static late bool alarmSensorDissconnected;

  static late bool allowLocalNotifications;
  static late bool notificationIsEnabled;

  static bool vibrationIsSupported = false;

  static const nameDeviceOldSensor = 'temperature sensor';
  static const prefixDeviceNewSensor = 'ThermoD';
  
  static List<String> remoteIds = [];
  static const uuidServiceTemperature = '181a';
  static const uuidCharacteristicTemperature = '2a6e';
  static const uuidServiceBattery = '180f';
  static const uuidCharacteristicBattery = '2a19';

  static const typeRing = 'ring';
  static const typeVibration = 'vibration';
  static const typeNone = 'none';

  static String changeTypeNotify(String currentType) {
    switch (currentType) {
      case typeRing :
        if (vibrationIsSupported) {
          Vibration.vibrate();
          return typeVibration;
        }
        return typeNone;
      case typeVibration :
        return typeNone;
      case typeNone :
      default :
        _player.play(AssetSource('../${AppAssets.alarmAudio}'), position: const Duration(seconds: 3)); //всего 4 сек длится, ограничиваем
        return typeRing;
    }
  }

  static Future<void> init() async {
    log(useOnlyV1.toString(), name: 'use_only_v1');
    envDebug = foundation.kReleaseMode ? false : true;
    maxHoursForChart = await _dataProvider.getMaxHoursForStat();
    await _dataProvider.loadingChart();
    notifyWhenTempDrops = await _dataProvider.getNotifyWhenTempDrops();
    notifyWhenTimerEnds = await _dataProvider.getNotifyWhenTimerEnds();
    calibrationSensor = await _dataProvider.getCalibrationSensor();
    hidePercentSpiritWidget = await _dataProvider.getHidePercentSpiritWidget();
    alarmLowBatteryCharge = await _dataProvider.getAlarmLowBatteryCharge();
    wakelock = await _dataProvider.getWakelock();
    alarmSensorDissconnected = await _dataProvider.getAlarmSensorDissconnected();
    allowLocalNotifications = await _dataProvider.getAllowLocalNotifications();
  }
}