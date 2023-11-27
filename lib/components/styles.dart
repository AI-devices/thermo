import 'package:flutter/material.dart';

abstract class AppStyle {

  static const barColor = Color.fromRGBO(54, 68, 117, 1);

  static const backgroundColor = Color.fromRGBO(255, 255, 255, 1);

  static final decorMainCotnainers = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.black.withOpacity(0.2)),
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2)
      )
    ]
  );

  static Color getColorByTemp({required num? temperature}) {
    if (temperature == null) return Colors.white;
    int index = 0;
    if (temperature > 50) {
      //?Colors.yellow.withGreen() двигаясь от 255 до 0 идем от желтого к красному
      if (temperature >= 100) {
        index = 0;
      } else if(temperature == 51) {
        index = 255;
      } else {
        index = (255 - ((temperature - 50) * 5)).round();
      }
      return Colors.yellow.withGreen(index).withOpacity(0.3);
    } else {
      //?Colors.blue.withBlue() двигаясь от 255 до 0 идем от синего к зеленому
      if (temperature <= 0) {
        index = 255;
      } else if(temperature == 50) {
        index = 0;
      } else {
        index = (255 - (temperature * 5)).round();
      }
      return Colors.blue.withBlue(index).withOpacity(0.3);
    }
  }

  /*static Color getColorByTemp({required num? temperature}) {
    if (temperature == null) return Colors.white;
    if (temperature < 10) return Colors.blue.withOpacity(0.2);
    if (temperature < 35) return Colors.green.withOpacity(0.2);
    if (temperature < 50) return Colors.yellow.withOpacity(0.2);
    if (temperature < 70) return Colors.orange.withOpacity(0.2);
    return Colors.red.withOpacity(0.2);
  }*/

  static Icon getIconBluetooth(bool? status) {
    switch (status) {
      case null :
        return const Icon(Icons.bluetooth, color: Colors.white);
      case true:
        return const Icon(Icons.bluetooth_connected, color: Colors.green);
      case false:
        return const Icon(Icons.bluetooth_disabled, color: Colors.red);
    }
  }
  static Icon getIconSensor(bool? status) {
    switch (status) {
      case null :
        return const Icon(Icons.thermostat, color: Colors.white);
      case true:
        return const Icon(Icons.thermostat, color: Colors.green);
      case false:
        return const Icon(Icons.thermostat, color: Colors.red);
    }
  }
  static Icon getIconBattery(int? charge) {
    if (charge == null) return const Icon(Icons.battery_unknown, color: Colors.white);
    if (charge < 5) return const Icon(Icons.battery_0_bar, color: Colors.white);
    if (charge < 15) return const Icon(Icons.battery_1_bar, color: Colors.white);
    if (charge < 30) return const Icon(Icons.battery_2_bar, color: Colors.white);
    if (charge < 45) return const Icon(Icons.battery_3_bar, color: Colors.white);
    if (charge < 60) return const Icon(Icons.battery_4_bar, color: Colors.white);
    if (charge < 75) return const Icon(Icons.battery_5_bar, color: Colors.white);
    if (charge < 90) return const Icon(Icons.battery_6_bar, color: Colors.white);
    return const Icon(Icons.battery_full, color: Colors.white);
  }
}