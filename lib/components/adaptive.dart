import 'package:flutter/material.dart';

abstract class Adaptive {
  //!через глобальное св-во navigatorKey.currentState!.context не использовать
  static double text(double size, BuildContext context) {
    if (size == 12) return MediaQuery.of(context).size.width * 0.029;
    if (size == 13) return MediaQuery.of(context).size.width * 0.0315;
    if (size == 14) return MediaQuery.of(context).size.width * 0.034;
    if (size == 15) return MediaQuery.of(context).size.width * 0.0365;
    if (size == 16) return MediaQuery.of(context).size.width * 0.039;
    if (size == 18) return MediaQuery.of(context).size.width * 0.044;
    return size;
  }

  static double icon(double size, BuildContext context) {
    if (size == 30) return MediaQuery.of(context).size.width * 0.07;
    if (size == 62) return MediaQuery.of(context).size.width * 0.15;
    return size;
  }

  static double padding(double size, BuildContext context) {
    if (size == 10) return MediaQuery.of(context).size.width * 0.02;
    return size;
  }
}