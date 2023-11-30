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
  static const alarmWhenTempDrops = 'alarm_when_temp_drops';
}

class DataProvider {

  static final _sharedPreferences = SharedPreferences.getInstance();

  Future<List<dynamic>> getControlPoints() async {
    final pointsEncoded = (await _sharedPreferences).getString(_Keys.controlPoints);
    if (pointsEncoded == null) {
      return [
        { 'value' : 25, 'notify' : Settings.typeRing },
        { 'value' : 50, 'notify' : Settings.typeRing },
        { 'value' : 75, 'notify' : Settings.typeRing },
        { 'value' : 100, 'notify' : Settings.typeRing },
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

  Future<String> getAlarmWhenTempDrops() async {
    return (await _sharedPreferences).getString(_Keys.alarmWhenTempDrops) ?? Settings.typeNone;
  }
  Future<void> setAlarmWhenTempDrops() async {
    await (await _sharedPreferences).setString(_Keys.alarmWhenTempDrops, Settings.alarmWhenTempDrops);
  }
}