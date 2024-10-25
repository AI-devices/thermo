import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

abstract class Helper {

  static const String celsius = ' \u2103';

  static final loader = Center(child: Platform.isAndroid
      ? const CircularProgressIndicator(color: AppStyle.mainColor)
      : const CupertinoActivityIndicator());

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? 
    viewSnackBar({
      required BuildContext context, 
      required String text, 
      int? duration,
      Icon? icon
    }) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            if (icon == null)
            const Icon(Icons.done, color: AppStyle.mainColor)
            else
            icon,
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
        duration: Duration(seconds: duration is int ? duration : 3),
        behavior: SnackBarBehavior.floating,
        width: double.infinity,
      ));
  }

  //парсит данные по температуре полученные от датчика
  static double parseTemperature(List<int> data) {
    //print(Uint8List.fromList(data).buffer.asInt16List());
    double temperature = (Uint8List.fromList(data).buffer.asByteData().getUint16(0, Endian.little)) / 100;
    return temperature + Settings.calibrationSensor;
  }

  static int getDurationInSeconds(String time) {
    final digits = time.replaceAll(RegExp(r'[^0-9]'),'');
    return int.parse(digits.substring(4)) + (int.parse(digits.substring(2,4)) * 60) + (int.parse(digits.substring(0,2)) * 3600);
  }

  static Future<dynamic> alert ({
    required BuildContext context,
    required String content,
    bool choice = false,
    VoidCallback? cancelAction,
    VoidCallback? confirmAction,
    VoidCallback? closeAction,
    String? cancelText,
    String? confirmText,
    String? title,
  }) async {
    return showDialog<dynamic>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            titlePadding: const EdgeInsets.only(left: 25),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(title ?? Lang.text('Предупреждение'), style: const TextStyle(color: AppStyle.greyColor)),
                ),
                IconButton(
                  onPressed: closeAction ?? () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppStyle.greyColor, size: 38)
                )
              ],
            ),
            content: Text(content, style: const TextStyle(fontSize: 15)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10) 
            ),
            actions: <Widget>[
              if (choice == false)
                InkWell(
                  onTap: confirmAction ?? () => Navigator.of(context).pop(),
                  child: AppStyle.getButton(color: AppStyle.colorButtonGreen, text: 'OK')
                )
              else  
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: cancelAction ?? () => Navigator.of(context).pop(),
                      child: AppStyle.getButtonCancel(text: cancelText ?? Lang.text('Нет'))
                    ),
                    InkWell(
                      onTap: confirmAction ?? () => Navigator.of(context).pop(),
                      child: AppStyle.getButton(color: AppStyle.colorButtonGreen, text: confirmText ?? Lang.text('Да'))
                    ),
                  ],
                )
            ],
          )
        );
      },
    );
  }

  static Switch switcher ({required bool value, required Function(bool) action}) {
    return Switch(
      trackOutlineColor: MaterialStateProperty.all(Colors.white.withOpacity(0)), //прозрачный border
      thumbIcon: MaterialStateProperty.all(const Icon(null)), //размер круга внутри Switch в состоянии off становится таким же как в on
      inactiveTrackColor: const Color.fromARGB(255, 221, 221, 221),
      inactiveThumbColor: Colors.white,
      activeTrackColor: AppStyle.mainColor,
      activeColor: Colors.white,
      value: value,
      onChanged: action,
    );
  }
}