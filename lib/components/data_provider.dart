import 'dart:convert';
import 'package:thermo/components/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class _Keys {
  static const controlPoints = 'control_points';
  static const lastTimers = 'last_timers';
  static const maxHoursForStat = 'max_hours_for_stat';
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
}