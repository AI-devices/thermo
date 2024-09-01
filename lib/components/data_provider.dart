import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:thermo/components/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class _Keys {
  static const controlPoints = 'control_points';
  static const lastTimers = 'last_timers';
  static const maxHoursForStat = 'max_hours_for_stat';
  static const coordinatesChart = 'coordinates_chart';
  static const scaleAxisX = 'scale_axis_x';
  static const notifyWhenTempDrops = 'notify_when_temp_drops';
  static const notifyWhenTimerEnds = 'notify_when_timer_ends';
  static const calibrationSensor = 'calibration_sensor';
  static const hidePercentSpiritWidget = 'hide_percent_spirit_widget';
  static const alarmLowBatteryCharge = 'alarm_low_battery_charge';
  static const wakelock = 'wakelock';
  static const alarmSensorDissconnected = 'alarm_sensor_dissconnected';
  static const allowLocalNotifications = 'allow_local_notifications';
}

class DataProvider {

  static final _sharedPreferences = SharedPreferences.getInstance();

  Future<List<dynamic>> getControlPoints() async {
    final pointsEncoded = (await _sharedPreferences).getString(_Keys.controlPoints);
    if (pointsEncoded == null) {
      return [
        { 'value' : 25.0, 'notify' : Settings.typeRing },
        { 'value' : 50.0, 'notify' : Settings.typeRing },
        { 'value' : 75.0, 'notify' : Settings.typeRing },
        { 'value' : 99.0, 'notify' : Settings.typeRing },
      ];
    }
    List<dynamic> points = json.decode(pointsEncoded);
    return points;
  }
  Future<void> setControlPoints(List<dynamic> points) async {
    await (await _sharedPreferences).setString(_Keys.controlPoints, json.encode(points));
  }

  Future<List<dynamic>> getLastTimers() async {
    final lastTimers = (await _sharedPreferences).getString(_Keys.lastTimers);
    if (lastTimers == null) return [];
    return json.decode(lastTimers);
  }
  Future<void> saveLastTimers(List<dynamic> lastTimers) async {
    await (await _sharedPreferences).setString(_Keys.lastTimers, json.encode(lastTimers));
  }

  Future<int> getMaxHoursForStat() async {
    return (await _sharedPreferences).getInt(_Keys.maxHoursForStat) ?? 3;
  }
  Future<void> setMaxHoursForStat(int value) async {
    await (await _sharedPreferences).setInt(_Keys.maxHoursForStat, value);
  }

  Future<void> loadingChart() async {
    Settings.scaleAxisX = (await _sharedPreferences).getDouble(_Keys.scaleAxisX) ?? 300; //1 деление по оси X - 5 мин (300 сек)

    final coordinatesEncoded = (await _sharedPreferences).getString(_Keys.coordinatesChart);
    if (coordinatesEncoded == null) {
      Settings.coordinatesChart = [const FlSpot(0, 0)];
      return;
    }
    List<dynamic> coordinates = json.decode(coordinatesEncoded);
    Settings.coordinatesChart = coordinates.map((e) => FlSpot(e['x'], e['y'])).toList();
  }
  Future<void> saveAxisX() async {
    await (await _sharedPreferences).setDouble(_Keys.scaleAxisX, Settings.scaleAxisX);
  }
  Future<void> saveCoordinates() async {
    final coordinates = Settings.coordinatesChart.map((e) => {'x' : e.x, 'y' : e.y}).toList();
    await (await _sharedPreferences).setString(_Keys.coordinatesChart, json.encode(coordinates));
  }

  Future<String> getNotifyWhenTempDrops() async {
    return (await _sharedPreferences).getString(_Keys.notifyWhenTempDrops) ?? Settings.typeNone;
  }
  Future<void> setNotifyWhenTempDrops() async {
    await (await _sharedPreferences).setString(_Keys.notifyWhenTempDrops, Settings.notifyWhenTempDrops);
  }
  Future<String> getNotifyWhenTimerEnds() async {
    return (await _sharedPreferences).getString(_Keys.notifyWhenTimerEnds) ?? Settings.typeRing;
  }
  Future<void> setNotifyWhenTimerEnds() async {
    await (await _sharedPreferences).setString(_Keys.notifyWhenTimerEnds, Settings.notifyWhenTimerEnds);
  }

  Future<double> getCalibrationSensor() async {
    return (await _sharedPreferences).getDouble(_Keys.calibrationSensor) ?? 0.0;
  }
  Future<void> setCalibrationSensor() async {
    (await _sharedPreferences).setDouble(_Keys.calibrationSensor, Settings.calibrationSensor);
  }

  Future<bool> getHidePercentSpiritWidget() async {
    return (await _sharedPreferences).getBool(_Keys.hidePercentSpiritWidget) ?? false;
  }
  Future<void> setHidePercentSpiritWidget() async {
    (await _sharedPreferences).setBool(_Keys.hidePercentSpiritWidget, Settings.hidePercentSpiritWidget);
  }

  Future<Map<String, dynamic>> getAlarmLowBatteryCharge() async {

    final data = (await _sharedPreferences).getString(_Keys.alarmLowBatteryCharge);
    if (data == null) return { 'on' : false, 'percent_charge' : '20' };
    return json.decode(data);
  }
  Future<void> setAlarmLowBatteryCharge() async {
    (await _sharedPreferences).setString(_Keys.alarmLowBatteryCharge, json.encode(Settings.alarmLowBatteryCharge));
  }

  Future<bool> getWakelock() async {
    return (await _sharedPreferences).getBool(_Keys.wakelock) ?? false;
  }
  Future<void> setWakelock() async {
    (await _sharedPreferences).setBool(_Keys.wakelock, Settings.wakelock);
  }

  Future<bool> getAlarmSensorDissconnected() async {
    return (await _sharedPreferences).getBool(_Keys.alarmSensorDissconnected) ?? true;
  }
  Future<void> setAlarmSensorDissconnected() async {
    (await _sharedPreferences).setBool(_Keys.alarmSensorDissconnected, Settings.alarmSensorDissconnected);
  }

  Future<bool> getAllowLocalNotifications() async {
    return (await _sharedPreferences).getBool(_Keys.allowLocalNotifications) ?? true;
  }
  Future<void> setAllowLocalNotifications() async {
    (await _sharedPreferences).setBool(_Keys.allowLocalNotifications, Settings.allowLocalNotifications);
  }
}