import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/styles.dart';
import 'package:thermo/widgets/assets.dart';

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
  Icon? diffIcon;

  @override
  void initState() {
    super.initState();
    temperatureSubscription = ApiBluetooth.temperatureStream.listen((double temperature){
      currentTemperature = temperature;
      setState(() {});
    });
    statusSensorSubscription = ApiBluetooth.statusSensorStream.listen((bool statusSensor){
      if (statusSensor == false) {
        currentTemperature = null;
        setState(() {});
      }
    });
    _checkDiffTemperature();
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
      
      if (currentDiff > 0 && currentDiff > diff)  {
        diffIcon = const Icon(Icons.keyboard_double_arrow_up, size: 24);
      } else if (currentDiff > 0 && currentDiff < diff) {
        diffIcon = const Icon(Icons.keyboard_arrow_up, size: 24);
      } else if (currentDiff < 0 && currentDiff > diff) {
        diffIcon = const Icon(Icons.keyboard_double_arrow_down, size: 24);
      } else {
        diffIcon = const Icon(Icons.keyboard_arrow_down, size: 24);
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
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 30),
          Padding(
            padding: EdgeInsets.fromLTRB(2, 10, 2, 0),
            child: Text('Ожидается подключение к датчику', textAlign: TextAlign.center),
          )
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.getColorByTemp(temperature: currentTemperature),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                child: const SizedBox(),
              ),
            ),
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: currentTemperature?.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 25)
                          ),
                          const TextSpan(
                            text: Helper.celsius,
                            style: TextStyle(fontSize: 16)
                          )
                        ],
                      ),
                    ),
                    
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          flex: 1,
                          child: (diffIcon != null && diff != 0.0) ? diffIcon! : const SizedBox(),
                        ),
                        Flexible(
                          flex: 3,
                          child: Text(diff.toString(), style: const TextStyle(
                            color: Colors.black, 
                            fontWeight: FontWeight.bold,
                            fontSize: 24
                          )),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: 17,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: AppAssets.iconDelta,
                            ),
                          ),
                        )
                        /*const SizedBox(width: 5),
                        const Flexible(
                          flex: 1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(Helper.celsius, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Divider(color: Colors.black, height: 0),
                              Text('мин', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        )*/
                      ],
                    )
                  ],
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}