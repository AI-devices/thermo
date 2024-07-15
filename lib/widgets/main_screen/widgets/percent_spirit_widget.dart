import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';
import '../../../components/constants.dart' as constants;

class PercentSpiritWidget extends StatefulWidget {
  const PercentSpiritWidget({Key? key}) : super(key: key);

  @override
  State<PercentSpiritWidget> createState() => _PercentSpiritWidgetState();
}

class _PercentSpiritWidgetState extends State<PercentSpiritWidget> {
  StreamSubscription<double>? temperatureSubscription;
  double? tempInCube;
  double? tempInSampling;

  @override
  void initState() {
    super.initState();
    Settings.hidePercentSpiritWidgetChanged ??= () => setState(() {});
    temperatureSubscription = ApiBluetooth.temperatureStream.listen((double temperature){
      if (temperature < 79 || temperature > 99) return;
      temperature = _parseTemp(temperature);
      if (constants.dictSpiritByTemp[temperature] == null) return;
      tempInCube = constants.dictSpiritByTemp[temperature]!['temp_in_cube'];
      tempInSampling = constants.dictSpiritByTemp[temperature]!['temp_in_sampling'];
      setState(() {});
    });
  }

  //округляем до точности шагом в 0.25
  double _parseTemp(double temperature) {
    return (double.parse((temperature * 4).toStringAsFixed(0)) / 4).toPrecision(2);
  }

  @override
  void dispose() {
    temperatureSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: Settings.hidePercentSpiritWidget == false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        height: MediaQuery.of(context).size.height * 0.09,
        width: double.infinity,
        decoration: AppStyle.decorMainCotnainers,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Спиртуозность, %AC', style: TextStyle(fontSize: 15)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('в кубе:'),
                Text(tempInCube != null ? tempInCube.toString() : '---', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('|'),
                const Text('в отборе:'),
                Text(tempInSampling != null ? tempInSampling.toString() : '---', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}