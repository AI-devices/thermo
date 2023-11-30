import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:thermo/components/api_bluetooth.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/widgets/assets.dart';
import 'package:vibration/vibration.dart';

class Monitoring {
  static Monitoring? _instance;
  StreamSubscription<double>? temperatureSubscription;
  final _player = AudioPlayer();

  int _countTempDrops = 0;
  double _lastTemp= 0;

  factory Monitoring() {
    return _instance ??= Monitoring._();
  }

  Monitoring._() {
    temperatureSubscription = ApiBluetooth.temperatureStream.listen((double temperature) => _alarmWhenTempDrops(temperature));
  }

  _alarmWhenTempDrops(double temperature) {
    if (temperature > _lastTemp) {
      _countTempDrops = 0;
    } else {
      _countTempDrops += 1;
    }
    _lastTemp = temperature;
    if (_countTempDrops == 5) {
      _countTempDrops = 0;
      if (Settings.alarmWhenTempDrops == Settings.typeVibration) Vibration.vibrate(duration: 2000);
      if (Settings.alarmWhenTempDrops == Settings.typeRing) {
        _player.play(AssetSource('../${AppAssets.alarmAudio}'), position: const Duration(seconds: 0));
      }
    }
  }
}