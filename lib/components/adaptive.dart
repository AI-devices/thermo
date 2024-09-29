import 'package:flutter/material.dart';
import 'package:thermo/main.dart';

abstract class Adaptive {
  static final double _screenWidth = MediaQuery.of(navigatorKey.currentState!.context).size.width;
  //static final double _screenHeight = MediaQuery.of(navigatorKey.currentState!.context).size.height;

  static double text(double size) {
    if (size == 12) return _screenWidth * 0.029;
    if (size == 13) return _screenWidth * 0.0315;
    if (size == 14) return _screenWidth * 0.034;
    if (size == 15) return _screenWidth * 0.0365;
    if (size == 16) return _screenWidth * 0.039;
    if (size == 18) return _screenWidth * 0.044;
    return size;
  }

  static double icon(double size) {
    if (size == 30) return _screenWidth * 0.07;
    if (size == 62) return _screenWidth * 0.15;
    return size;
  }

  static double padding(double size) {
    if (size == 10) return _screenWidth * 0.02;
    return size;
  }
}