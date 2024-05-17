import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth.dart';
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
    if (ApiBluetooth.statusSensor == false) {
      if (charge == null) return;
      charge = null;
      changeBatteryCharge?.call();
      return;
    }
    
    final currentCharge = await ApiBluetooth.getBatteryCharge();
    if (currentCharge == charge) return;

    charge = currentCharge;
    changeBatteryCharge?.call();
    if (charge != null) {
      if (charge! < int.parse(Settings.alarmLowBatteryCharge['percent_charge'])) _alert();
      if (charge! >= int.parse(Settings.alarmLowBatteryCharge['percent_charge']) && _alertLowBatteryCharge == true) _alertLowBatteryCharge = false;
    }
  }

  void _alert() {
    if ((Settings.alarmLowBatteryCharge['on'] as bool) == false) return;
    if (_alertLowBatteryCharge == true) return;
    _alertLowBatteryCharge = true;

    _player.play(AssetSource('../${AppAssets.alarmAudioLong}'));

    showDialog<dynamic>(
      context: navigatorKey.currentState!.context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            title: const Text('Предупреждение'),
            content: Text('Низкий заряд батареи ($charge%)'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10) 
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _player.stop();
                }, 
                child: const Text('OK'))
            ],
          )
        );
      },
    );
  }
}