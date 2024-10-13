import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thermo/components/adaptive.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';
import '../../../components/constants.dart' as constants;

class PercentSpiritWidget extends StatefulWidget {
  const PercentSpiritWidget({Key? key}) : super(key: key);

  @override
  State<PercentSpiritWidget> createState() => _PercentSpiritWidgetState();
}

class _PercentSpiritWidgetState extends State<PercentSpiritWidget> {
  final _dataProvider = DataProvider();
  StreamSubscription<double>? temperatureSubscription;
  StreamSubscription<void>? hidePercentSpiritWidgetSubscription;
  double? tempInCube;
  double? tempInSampling;

  @override
  void initState() {
    super.initState();
    hidePercentSpiritWidgetSubscription = Settings.hidePercentSpiritWidgetStream.listen((_){
      setState(() {});
    });
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
    hidePercentSpiritWidgetSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Settings.hidePercentSpiritWidget == false ? _show(context) : _hide(context);
  }

  Container _show(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: double.infinity,
      decoration: AppStyle.decorMainContainer,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              width: 43,
              height: 43,
              decoration: AppStyle.decorMainContainer,
              child: IconButton(
                icon: const Icon(Icons.close), 
                onPressed: () {
                  Settings.hidePercentSpiritWidget = true;
                  _dataProvider.setHidePercentSpiritWidget();
                  Settings.controllerHidePercentSpiritWidget.add(null);
                },
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(Lang.text('Спиртуозность, %AC'), style: TextStyle(fontSize: Adaptive.text(15, context))),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Lang.text('в кубе: '), style: TextStyle(fontSize: Adaptive.text(15, context))),
                  Text(tempInCube != null ? '$tempInCube%' : '---', style: TextStyle(fontWeight: FontWeight.bold, fontSize: Adaptive.text(15, context))),
                  Text(' | ', style: TextStyle(fontSize: Adaptive.text(15, context))),
                  Text(Lang.text('в отборе: '), style: TextStyle(fontSize: Adaptive.text(15, context))),
                  Text(tempInSampling != null ? '$tempInSampling%' : '---', style: TextStyle(fontWeight: FontWeight.bold, fontSize: Adaptive.text(15, context))),
                ],
              ),
              Text(Lang.text('Диапазон от 79 до 99 градусов'), style: TextStyle(fontSize: Adaptive.text(13, context), color: AppStyle.greyColor)),
            ],
          ),
        ],
      ),
    );
  }

  Row _hide(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            Settings.hidePercentSpiritWidget = false;
            _dataProvider.setHidePercentSpiritWidget();
            Settings.controllerHidePercentSpiritWidget.add(null);
          },
          child: Text(Lang.text('Показать спиртуозность'), style: TextStyle(fontSize: Adaptive.text(15, context), decoration: TextDecoration.underline, fontStyle: FontStyle.italic))
        ),
        const SizedBox(width: 15),
        Container(
          decoration: AppStyle.decorMainContainer,
          child: IconButton(
            icon: Icon(Icons.remove_red_eye_outlined, size: Adaptive.icon(30, context)), 
            onPressed: () {
              Settings.hidePercentSpiritWidget = false;
              _dataProvider.setHidePercentSpiritWidget();
              Settings.controllerHidePercentSpiritWidget.add(null);
            },
          ),
        )
      ],
    );
  }
}