import 'package:flutter/material.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final _dataProvider = DataProvider();
  double maxHoursForStat = Settings.maxHoursForStat.toDouble();

  void onChangedHours(double value) {
      maxHoursForStat = value;
      setState(() {});
  }

  void onChangedEnd(double value) {
    _dataProvider.setMaxHoursForStat(value.round());
    Settings.maxHoursForStat = value.round();
    Settings.maxHoursForStatChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 6,
                  child: Text('Максимальный масштаб статистики (${maxHoursForStat.round()} ч.)')
                ),
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
                          onChangeEnd: onChangedEnd,
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
            ),
            const Divider(color: Colors.black),
          ],
        ),
      ),
    );
  }
}