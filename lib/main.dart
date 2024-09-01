import 'package:flutter/material.dart';
import 'package:thermo/components/local_notification.dart';
import 'package:thermo/components/monitoring.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/widgets/my_app.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotification.init();
  await Settings.init();
  
  Monitoring();

  runApp(const MyApp());
}