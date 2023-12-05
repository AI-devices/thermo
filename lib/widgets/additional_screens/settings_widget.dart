import 'package:flutter/material.dart';
import 'package:thermo/components/data_provider.dart';
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
}