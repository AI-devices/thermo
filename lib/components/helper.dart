import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thermo/components/styles.dart';

abstract class Helper {

  static const String celsius = ' \u2103';

  static final loader = Center(child: Platform.isAndroid
      ? const CircularProgressIndicator(color: AppStyle.barColor)
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
            const Icon(Icons.done, color: Colors.green,)
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

  static void alert({
    required BuildContext context,
    String? content = 'Что-то пошло не так..',
    String? title,
  }) {
    content ??= 'Что-то пошло не так..';
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            title: Text(title ?? 'Предупреждение'),
            content: Text(content!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10) 
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), 
                child: const Text('OK'))
            ],
          )
        );
      },
    );
  }

  //парсит данные по температуре полученные от датчика
  static double parseTemperature(List<int> data) {
    //print(Uint8List.fromList(data).buffer.asInt16List());
    return (Uint8List.fromList(data).buffer.asByteData().getUint16(0, Endian.little)) / 100;
  }

  static int getDurationInSeconds(String time) {
    final digits = time.replaceAll(RegExp(r'[^0-9]'),'');
    return int.parse(digits.substring(4)) + (int.parse(digits.substring(2,4)) * 60) + (int.parse(digits.substring(0,2)) * 3600);
  }
}