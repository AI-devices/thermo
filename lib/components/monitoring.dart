import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/main.dart';
import 'package:thermo/widgets/assets.dart';
import 'package:vibration/vibration.dart';

class Monitoring {
  static Monitoring? _instance;
  StreamSubscription<double>? temperatureSubscription;
  final _player = AudioPlayer();
  final _dataProvider = DataProvider();

  int _countTempDrops = 0;
  double _lastTemp= 0;

  factory Monitoring() {
    return _instance ??= Monitoring._();
  }

  Monitoring._() {
    temperatureSubscription = ApiBluetooth.temperatureStream.listen((double temperature) => _notifyWhenTempDrops(temperature));
  }

  _notifyWhenTempDrops(double temperature) {
    if (temperature > _lastTemp) {
      _countTempDrops = 0;
    } else {
      _countTempDrops += 1;
    }
    _lastTemp = temperature;
    if (_countTempDrops == 5) {
      _countTempDrops = 0;
      if (Settings.notifyWhenTempDrops == Settings.typeVibration) Vibration.vibrate(duration: 2000);
      if (Settings.notifyWhenTempDrops == Settings.typeRing) {
        _player.play(AssetSource('../${AppAssets.alarmAudio}'), position: const Duration(seconds: 0));
      }
      if (Settings.notifyWhenTempDrops == Settings.typeNone) return;
      if (Navigator.of(navigatorKey.currentState!.context).canPop()) Navigator.of(navigatorKey.currentState!.context).pop();

      Helper.alert(
        choice: true,
        title: Lang.text('Уведомление'),
        context: navigatorKey.currentState!.context, 
        content: Lang.text('Температура падает'), 
        cancelText: Lang.text('Не следить'),
        confirmText: Lang.text('Продолжить'),
        cancelAction: () {
          Settings.notifyWhenTempDrops = Settings.typeNone;
          _dataProvider.setNotifyWhenTempDrops();
          Settings.notifyWhenTempDropsChanged?.call();
          Navigator.of(navigatorKey.currentState!.context).pop();
        }
      );
    }
  }
}