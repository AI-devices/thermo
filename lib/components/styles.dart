import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

abstract class AppStyle {

  static const mainColor = Color.fromRGBO(52, 199, 89, 1);
  static const headerColor = Color.fromRGBO(74, 74, 74, 1);
  static const backgroundColor = Color.fromRGBO(237, 240, 245, 1);
  static const decorColor = Color.fromARGB(255, 238, 238, 241);

  static const greyColor = Color.fromRGBO(106, 106, 106, 1);
  static const dottedColor = Color.fromRGBO(146, 146, 146, 1);
  static const pinkColor = Color.fromRGBO(255, 0, 255, 1);

  static BoxDecoration getDecorMainContainerByTemp({required double temp}) {
    return BoxDecoration(
      border: Border.all(color: AppStyle.getColorByTemp(temperature: temp)),
      color: decorColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: AppStyle.getColorByTemp(temperature: temp),
          blurRadius: 1.0,
          spreadRadius: 3.0
        ),
      ]
    );
  }

  static final decorMainContainer = BoxDecoration(
    color: decorColor,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.white),
    boxShadow: [
      boxShadowBottomRight(),
      boxShadowTopLeft(),
    ]
  );

  static final decorMainCotnainerInset = BoxDecoration(
    color: decorColor,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      boxShadowBottomRight(true),
      boxShadowTopLeft(true),
    ]
  );

  static boxShadowBottomRight([bool inset = false]) {
    return BoxShadow(
      color: const Color.fromARGB(255, 176, 176, 177),
      offset: const Offset(2.0, 2.0),
      blurRadius: 3.0,
      spreadRadius: 1.0,
      inset: inset
    );
  }

  static boxShadowTopLeft([bool inset = false]) {
    return BoxShadow(
      color: Colors.white,
      offset: const Offset(-2.0, -2.0),
      blurRadius: 5.0,
      spreadRadius: 1.0,
      inset: inset
    );
  }

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

  static Icon getIconBluetooth(bool? status) {
    switch (status) {
      case null :
        return const Icon(Icons.bluetooth, color: Colors.white);
      case true:
        return const Icon(Icons.bluetooth_connected, color: mainColor);
      case false:
        return const Icon(Icons.bluetooth_disabled, color: Colors.red);
    }
  }
  static Icon getIconSensor(bool? status) {
    switch (status) {
      case null :
        return const Icon(Icons.thermostat, color: Colors.white);
      case true:
        return const Icon(Icons.thermostat, color: mainColor);
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

  static const colorButtonGreen = mainColor;
  static const colorButtonRed = Color.fromARGB(255, 234, 20, 5);
  static const colorButtonOrange = Color.fromARGB(255, 255, 153, 0);
  static const colorButtonBlue = Color.fromARGB(255, 19, 173, 173);
  static getButton({required Color color, required String text}) {
    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white),
        boxShadow: [boxShadowBottomRight()]
      ),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15), overflow: TextOverflow.ellipsis)),
    );
  }
  static getButtonCancel({required String text}) {
    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: mainColor),
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        //boxShadow: [boxShadowBottomRight()]
      ),
      child: Center(child: Text(text, style: const TextStyle(color: mainColor, fontSize: 15), overflow: TextOverflow.ellipsis)),
    );
  }
}