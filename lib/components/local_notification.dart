import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';

class LocalNotification {
  static LocalNotification? _instance;
  StreamSubscription<double>? temperatureSubscription;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory LocalNotification() {
    return _instance ??= LocalNotification._();
  }

  LocalNotification._() {
    temperatureSubscription = ApiBluetooth.temperatureStream.listen((double temperature) => _showTemperatureNotification(temperature));
  }

  //? initialize the local notifications
  static Future<void> init() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: (id, title, body, payload) {}); //only iOS
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
          defaultActionName: 'Open notification');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);
  _flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (details) {});
  }

  static Future<void> _showTemperatureNotification(double temperature) async {
    if (Settings.notificationIsEnabled == false || Settings.allowLocalNotifications == false) return;
    
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'temperature channel',
        'temperature channel',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        progress: temperature.toInt(),
        maxProgress: 100,
        ongoing: true,
        autoCancel: false,
        silent: true,
        timeoutAfter: 10000, //скрываем уведомление через 10 сек (например закрыли приложение, чтобы уведомление не оставалось)
        color: AppStyle.getColorByTemp(temperature: temperature)
      );
      NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.show(0, Lang.text('температура датчика: %s', ['${temperature.toStringAsFixed(1)}${Helper.celsius}']), 
        null, notificationDetails);
  }

  static Future cancelNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}