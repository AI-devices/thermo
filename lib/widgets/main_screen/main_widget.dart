import 'package:flutter/material.dart';
import 'package:thermo/components/styles.dart';
import 'package:thermo/widgets/main_screen/widgets/count_down_widget.dart';
import 'package:thermo/widgets/main_screen/widgets/control_points_widget.dart';
import 'package:thermo/widgets/main_screen/widgets/monitoring_widget.dart';
import 'package:thermo/widgets/main_screen/widgets/statistics_widget.dart';
import 'package:thermo/widgets/main_screen/widgets/timer_widget.dart';


class MainScreenWidget extends StatelessWidget {
  const MainScreenWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        children: [
          //? все виджеты здесь используют доступную высоту дисплея на 84%
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const _MonitoringWidget(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const _StatisticsWidget(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const _SettingWidget(),
        ],
      )
    ); 
  }
}

class _MonitoringWidget extends StatelessWidget {
  const _MonitoringWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Expanded(child: TimerWidget()),
          const SizedBox(width:  10),
          Expanded(child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppStyle.decorMainCotnainers,
            child: const MonitoringWidget(),
          )),
        ],
      )
    );
  }
}

class _StatisticsWidget extends StatelessWidget {
  const _StatisticsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      decoration: AppStyle.decorMainCotnainers,
      child: const StatisticsWidget(),
    );
  }
}

class _SettingWidget extends StatelessWidget {
  const _SettingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.26,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Expanded(child: CountDownWidget()),
          const SizedBox(width:  10,),
          Expanded(child: ControlPointsWidget.create()),
        ],
      )
    );
  }
}