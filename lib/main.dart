import 'package:flutter/material.dart';
import 'package:thermo/components/monitoring.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/widgets/my_app.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Monitoring();
  await Settings.init();
  
  runApp(const MyApp());
}