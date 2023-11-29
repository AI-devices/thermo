import 'package:flutter/material.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/widgets/my_app.dart';
import 'package:flutter/foundation.dart' as foundation;

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dataProvider = DataProvider();

  Settings.envDebug = foundation.kReleaseMode ? false : true;
  Settings.maxHoursForChart = await dataProvider.getMaxHoursForStat();
  await dataProvider.loadingChart();
  
  runApp(const MyApp());
}