import 'package:flutter/material.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/monitoring.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/widgets/my_app.dart';
import 'package:flutter/foundation.dart' as foundation;

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dataProvider = DataProvider();
  Monitoring();

  Settings.envDebug = foundation.kReleaseMode ? false : true;
  Settings.maxHoursForChart = await dataProvider.getMaxHoursForStat();
  await dataProvider.loadingChart();
  Settings.notifyWhenTempDrops = await dataProvider.getNotifyWhenTempDrops();
  Settings.notifyWhenTimerEnds = await dataProvider.getNotifyWhenTimerEnds();
  Settings.calibrationSensor = await dataProvider.getCalibrationSensor();
  Settings.hidePercentSpiritWidget = await dataProvider.getHidePercentSpiritWidget();
  
  runApp(const MyApp());
}