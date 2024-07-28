import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {

  static AppLifecycleState? state;
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLifecycleObserver.state = state;
    log(name: 'AppLifecycleObserver', state.toString());
    switch (state) {
      case AppLifecycleState.paused:
        ApiBluetooth().switchVersion(toVersion: ApiBluetoothVersion.version2); //в фоне переключаем на 2 версию
        break;
      case AppLifecycleState.resumed:
        ApiBluetooth().switchVersion(toVersion: ApiBluetoothVersion.version1newSensor); //возвращаем 1 версию, если приложение снова стало активно
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