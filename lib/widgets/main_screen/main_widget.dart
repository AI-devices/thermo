import 'package:flutter/material.dart';
import 'package:thermo/components/styles.dart';
import 'package:thermo/widgets/main_screen/widgets/count_down_widget.dart';
import 'package:thermo/widgets/main_screen/widgets/control_points_widget.dart';
import 'package:thermo/widgets/main_screen/widgets/monitoring_widget.dart';
import 'package:thermo/widgets/main_screen/widgets/chart_widget.dart';
import 'package:thermo/widgets/main_screen/widgets/percent_spirit_widget.dart';
import 'package:thermo/widgets/main_screen/widgets/timer_widget.dart';


class MainScreenWidget extends StatelessWidget {
  const MainScreenWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const _MonitoringWidgets(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const PercentSpiritWidget(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const _ChartWidget(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const _TimeWidgets(),
        ],
      )
    ); 
  }
}

class _MonitoringWidgets extends StatelessWidget {
  const _MonitoringWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.22,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppStyle.decorMainCotnainers,
            child: const MonitoringWidget(),
          )),
          const SizedBox(width:  10),
          Expanded(child: ControlPointsWidget.create()),
        ],
      )
    );
  }
}

class _ChartWidget extends StatelessWidget {
  const _ChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: MediaQuery.of(context).size.height * 0.36,
      width: double.infinity,
      decoration: AppStyle.decorMainCotnainers,
      child: const ChartWidget(),
    );
  }
}

class _TimeWidgets extends StatelessWidget {
  const _TimeWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.23,
      width: double.infinity,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: TimerWidget()),
          SizedBox(width:  10,),
          Expanded(child: CountDownWidget()),
        ],
      )
    );
  }
}