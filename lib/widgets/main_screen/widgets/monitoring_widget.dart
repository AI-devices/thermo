import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thermo/components/adaptive.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';
import 'package:thermo/widgets/assets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MonitoringWidget extends StatefulWidget {
  const MonitoringWidget({super.key});

  @override
  State<MonitoringWidget> createState() => _MonitoringWidgetState();
}

class _MonitoringWidgetState extends State<MonitoringWidget> {
  StreamSubscription<double>? temperatureSubscription;
  StreamSubscription<bool>? statusSensorSubscription;

  double? currentTemperature;
  double? previousTemperature;
  double diff = 0.0;
  SvgPicture diffIcon = AppAssets.arrowRight;

  double positionFlaskDivider = 0.0; //0.16 это самый верх колбы в нашем случае, 0.0 - низ

  @override
  void initState() {
    super.initState();
    temperatureSubscription = ApiBluetooth.temperatureStream.listen((double temperature){
      //print('${ApiBluetooth.version} | temp: $temperature');
      currentTemperature = temperature;
      _changePositionFlaskDivider();
      setState(() {});
    });
    statusSensorSubscription = ApiBluetooth.statusSensorStream.listen((bool statusSensor){
      if (Settings.wakelock) statusSensor == false ? WakelockPlus.disable() : WakelockPlus.enable();
      if (statusSensor == true) {
        WakelockPlus.enable();
      }
      if (statusSensor == false) {
        currentTemperature = null;
        setState(() {});
      }
    });
    _checkDiffTemperature();
  }

  void _changePositionFlaskDivider() {
    final max = currentTemperature! > 100 ? 100 : currentTemperature!;
    positionFlaskDivider = (max < 0 ? 0 : max) / 625; //625 - нормализация температуры для виджета колбы
  }

  void _checkDiffTemperature() {
    previousTemperature ??= currentTemperature;
    Timer.periodic(const Duration(seconds: 5), (_) {
      if (currentTemperature == null) return;
      if (previousTemperature == null) {
        previousTemperature = currentTemperature;
        return;
      }

      final currentDiff = (currentTemperature! - previousTemperature!) * 12; //помножаем на 12 прогнозируя разницу температур за минуту (таймер 5 сек)
      
      if (currentDiff == 0)  {
        diffIcon = AppAssets.arrowRight;
      } else if (currentDiff > 3.375)  {
        diffIcon = AppAssets.arrowUp4;
      } else if (currentDiff > 2.25) {
        diffIcon = AppAssets.arrowUp3;
      } else if (currentDiff > 1.125) {
        diffIcon = AppAssets.arrowUp2;
      } else if (currentDiff > 0) {
        diffIcon = AppAssets.arrowUp1;
      } else if (currentDiff < 3.375) {
        diffIcon = AppAssets.arrowDown4;
      } else if (currentDiff < 2.25) {
        diffIcon = AppAssets.arrowDown3;
      } else if (currentDiff < 1.125) {
        diffIcon = AppAssets.arrowDown2;
      } else if (currentDiff < 0) {
        diffIcon = AppAssets.arrowDown1;
      }

      diff = double.parse(currentDiff.toStringAsFixed(1)).abs();
      previousTemperature = currentTemperature;
      setState(() {});
    });
  }

  @override
  void dispose() {
    temperatureSubscription?.cancel();
    statusSensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentTemperature == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppStyle.pinkColor, size: Adaptive.icon(62, context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
            child: Text(Lang.text('Ожидается подключение к датчику'), 
              textAlign: TextAlign.center, 
              style: TextStyle(color: AppStyle.pinkColor, fontSize: Adaptive.text(14, context))
            ),
          )
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withOpacity(0.6)),
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.1,
                    0.5,
                    0.9,
                  ],
                  colors: [
                    Colors.red,
                    Colors.yellow,
                    Colors.blue,
                  ],
                )
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * positionFlaskDivider),
                child: const Align(
                  alignment: Alignment.bottomCenter,
                  child: Divider(color: Colors.black, thickness: 3)
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: double.infinity,
              child: Padding(
                //? 3 небольшая корректировка относительно Divider(а) слева от этой иконки
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * positionFlaskDivider - 3),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Icon(Icons.navigate_before)
                ),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: AppStyle.getDecorMainContainerByTemp(temp: currentTemperature!),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: currentTemperature?.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 26)
                        ),
                        const TextSpan(
                          text: Helper.celsius,
                          style: TextStyle(fontSize: 26)
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 40, height: 30, child: diffIcon)
              ],
            )
          )
        ],
      ),
    );
  }
}