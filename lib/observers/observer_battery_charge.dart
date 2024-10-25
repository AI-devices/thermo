import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/main.dart';
import 'package:thermo/widgets/assets.dart';

class ObserverBatteryCharge {
  static ObserverBatteryCharge? _instance;
  final _player = AudioPlayer();

  static int? charge;
  static VoidCallback? changeBatteryCharge;
  static bool _alertLowBatteryCharge = false;

  factory ObserverBatteryCharge() {
    return _instance ??= ObserverBatteryCharge._();
  }

  ObserverBatteryCharge._() {
    _checkBatteryCharge();
    Timer.periodic(const Duration(seconds: 60), (_) async {
      await _checkBatteryCharge();
    });
  }

  Future<void> _checkBatteryCharge() async {
    if (ApiBluetooth.statusSensor == false) return;
    
    final currentCharge = await ApiBluetooth.getBatteryCharge();
    log(currentCharge.toString(), name: 'chargeBattery');
    if (currentCharge == charge || currentCharge == null) return;

    charge = currentCharge;
    changeBatteryCharge?.call();
    if (charge! < int.parse(Settings.alarmLowBatteryCharge['percent_charge'])) _alert();
    if (charge! >= int.parse(Settings.alarmLowBatteryCharge['percent_charge']) && _alertLowBatteryCharge == true) _alertLowBatteryCharge = false;
  }

  void _alert() {
    if ((Settings.alarmLowBatteryCharge['on'] as bool) == false) return;
    if (_alertLowBatteryCharge == true) return;
    _alertLowBatteryCharge = true;

    _player.play(AssetSource('../${AppAssets.alarmAudioLong}'));

    Helper.alert(
      context: navigatorKey.currentState!.context,
      content: Lang.text('Низкий заряд батареи (%s%)', [charge]),
      closeAction: () {
        Navigator.of(navigatorKey.currentState!.context).pop();
        _player.stop();
      },
      confirmAction: () {
        Navigator.of(navigatorKey.currentState!.context).pop();
        _player.stop();
      },
    );
  }
}