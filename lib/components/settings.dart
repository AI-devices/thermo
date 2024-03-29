import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/widgets/assets.dart';
import 'package:vibration/vibration.dart';

abstract class Settings {
  static final _player = AudioPlayer();
  static final _dataProvider = DataProvider();
  
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
  static late String notifyWhenTimerEnds;
  static late double calibrationSensor;
  static late bool hidePercentSpiritWidget;
  static VoidCallback? hidePercentSpiritWidgetChanged;

  static bool vibrationIsSupported = false;

  static const nameDevice = 'temperature sensor';
  static const uuidServiceTemperature = '0000181a-0000-1000-8000-00805f9b34fb';
  static const uuidCharacteristicTemperature = '00002a6e-0000-1000-8000-00805f9b34fb';
  static const uuidServiceBattery = '0000180f-0000-1000-8000-00805f9b34fb';
  static const uuidCharacteristicBattery = '00002a19-0000-1000-8000-00805f9b34fb';

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
}