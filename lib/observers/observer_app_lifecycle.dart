import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/settings.dart';

class ObserverAppLifecycle extends WidgetsBindingObserver {

  static AppLifecycleState? state;
  final ApiBluetooth _apiBluetooth = ApiBluetooth();
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (Settings.useOnlyV1) return;
    ObserverAppLifecycle.state = state;
    log(name: 'AppLifecycleObserver', state.toString());
    switch (state) {
      case AppLifecycleState.paused:
        Future.delayed(const Duration(seconds: 10), () { //делаем лаг в 10 сек, чтобы не переключать лишний раз, если ненадолго свернули приложение
          if (ObserverAppLifecycle.state == AppLifecycleState.paused) {
            _apiBluetooth.switchVersion(toVersion: ApiBluetoothVersion.version2); //в фоне переключаем на 2 версию
          }
        });
        break;
      case AppLifecycleState.resumed:
        _apiBluetooth.switchVersion(toVersion: ApiBluetoothVersion.version1newSensor); //возвращаем 1 версию, если приложение снова стало активно
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }

    super.didChangeAppLifecycleState(state);
  }

  void addLifecycleObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  void removeLifecycleObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }
}