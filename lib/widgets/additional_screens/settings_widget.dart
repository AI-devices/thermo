import 'package:flutter/material.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/notifier.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final _dataProvider = DataProvider();
  double maxHoursForStat = Settings.maxHoursForChart.toDouble();

  void onChangedHours(double value) {
      maxHoursForStat = value;
      setState(() {});
  }

  void onChangedHoursEnd(double value) {
    _dataProvider.setMaxHoursForStat(value.round());
    Settings.maxHoursForChart = value.round();
    Settings.maxHoursForChartChanged?.call();
  }

  void changeNotifyWhenTempDrops() {
    Settings.notifyWhenTempDrops = Settings.changeTypeNotify(Settings.notifyWhenTempDrops);
    _dataProvider.setNotifyWhenTempDrops();
    setState(() {});
  }

  void changeNotifyWhenTimerEnds() {
    Settings.notifyWhenTimerEnds = Settings.changeTypeNotify(Settings.notifyWhenTimerEnds);
    _dataProvider.setNotifyWhenTimerEnds();
    setState(() {});
  }

  void changeCalibrationSensor({required String action}) {
    if (action == 'sub') {
      if (Settings.calibrationSensor <= -5.0) {
        Helper.alert(context: context, content: 'Достигнуто минимальное значение калибровки');
        return;
      }
      Settings.calibrationSensor = double.parse((Settings.calibrationSensor - 0.1).toStringAsFixed(1));
    } else {
      if (Settings.calibrationSensor >= 5.0) {
        Helper.alert(context: context, content: 'Достигнуто максимальное значение калибровки');
        return;
      }
      Settings.calibrationSensor = double.parse((Settings.calibrationSensor + 0.1).toStringAsFixed(1));
    }
    _dataProvider.setCalibrationSensor();
    setState(() {});
  }

  void changeVisibilityPercentSpiritWidget() {
    Settings.hidePercentSpiritWidget = !Settings.hidePercentSpiritWidget;
    Settings.hidePercentSpiritWidgetChanged?.call();
    _dataProvider.setHidePercentSpiritWidget();
    setState(() {});
  }

  void changeNotifyAlarmLowBatteryCharge() {
    Settings.alarmLowBatteryCharge = !Settings.alarmLowBatteryCharge;
    _dataProvider.setAlarmLowBatteryCharge();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _maxHoursForStat(),
            const Divider(color: Colors.black),
            _notifyWhenTempDrops(),
            const Divider(color: Colors.black),
            _notifyWhenTimerEnds(),
            const Divider(color: Colors.black),
            _calibrationSensor(),
            const Divider(color: Colors.black),
            _percentSpirit(),
            const Divider(color: Colors.black),
            _alarmLowBatteryCharge(),
            const Divider(color: Colors.black),
          ],
        ),
      ),
    );
  }

  Row _maxHoursForStat() {
    return Row(
            children: [
              Flexible(
                flex: 6,
                child: Text('Максимальный масштаб статистики (${maxHoursForStat.round()} ч.)')
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 5,
                child: Column(
                  children: [
                    SliderTheme(
                      data: const SliderThemeData(
                        showValueIndicator: ShowValueIndicator.always,
                        thumbColor: AppStyle.barColor,
                        activeTrackColor: AppStyle.barColor,
                      ),
                      child: Slider(
                        inactiveColor: Colors.grey.shade400,
                        value: maxHoursForStat,
                        min: 2,
                        max: 9,
                        divisions: 9,
                        label: maxHoursForStat.round().toString(),
                        onChanged: onChangedHours,
                        onChangeEnd: onChangedHoursEnd,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                        children: [
                          Text('2',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                          Text('9',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Row _notifyWhenTempDrops() {
    return Row(
      children: [
        const Flexible(
          flex: 6,
          child: Text('Сигнал при падении температуры в течение 5 сек.')
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 5,
          child: InkResponse(
            onTap: changeNotifyWhenTempDrops,
            child: Center(child: Notifier.getNotifyIcon(type: Settings.notifyWhenTempDrops, size: 30, color: AppStyle.barColor))
          )
        )
      ],
    );
  }

  Padding _notifyWhenTimerEnds() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Flexible(
            flex: 6,
            child: Text('Сигнал при завершении таймера')
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 5,
            child: InkResponse(
              onTap: changeNotifyWhenTimerEnds,
              child: Center(child: Notifier.getNotifyIcon(type: Settings.notifyWhenTimerEnds, size: 30, color: AppStyle.barColor))
            )
          )
        ],
      ),
    );
  }

  Padding _calibrationSensor() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 4,
            child: Row(
              children: [
                const Text('Калибровка датчика'),
                IconButton(
                  onPressed: () => Helper.alert(context: context, title: 'Пояснение', content: 'Повышает или снижает показания датчика в приложении на указанное значение. Показания на экране датчика не корректируются.'),
                  icon: const Icon(Icons.question_mark, color: Color.fromARGB(255, 189, 188, 188))
                )
              ],
            )
          ),
          const SizedBox(width: 15),
          Flexible(
            flex: 1,
            child: InkResponse(
              onTap: () => changeCalibrationSensor(action: 'sub'),
              child: const Text(Helper.minus, style: TextStyle(fontSize: 30))
            )
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text(Settings.calibrationSensor.toString(), textAlign: TextAlign.right, style: const TextStyle(fontSize: 18))
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Align(
              alignment: Alignment.center,
              child: InkResponse(
                onTap: () => changeCalibrationSensor(action: 'add'),
                child: const Text(Helper.plus, style: TextStyle(fontSize: 30))
              ),
            )
          ),
        ],
      ),
    );
  }

  Padding _percentSpirit() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Flexible(
            flex: 6,
            child: Text('Cкрыть автоматический расчет спиртуозности')
          ),
          Flexible(
            flex: 1,
            child: IconButton(
              onPressed: () => Helper.alert(context: context, title: 'Пояснение', content: 'Приблизительный расчет спиртуозности в кубе и в отборе по температуре при нагреве в перегонном кубе. Диапазон температуры от 79 до 99 градусов.'),
              icon: const Icon(Icons.question_mark, color: Color.fromARGB(255, 189, 188, 188))
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 5,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 25),
                child: Switch(
                  //activeColor: AppStyle.barColor,
                  value: Settings.hidePercentSpiritWidget,
                  onChanged: (_) => changeVisibilityPercentSpiritWidget(),
                ),
              ),
            )
          )
        ],
      ),
    );
  }

  Padding _alarmLowBatteryCharge() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Flexible(
            flex: 6,
            child: Text('Предупреждение при заряде датчика 20% и ниже')
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 5,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Switch(
                  value: Settings.alarmLowBatteryCharge,
                  onChanged: (_) => changeNotifyAlarmLowBatteryCharge(),
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}