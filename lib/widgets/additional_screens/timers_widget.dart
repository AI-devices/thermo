import 'package:flutter/material.dart';
import 'package:thermo/widgets/additional_screens/count_down_widget.dart';
import 'package:thermo/widgets/additional_screens/timer_widget.dart';

class TimersWidget extends StatelessWidget {
  const TimersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: const [
        TimerWidget(),
        SizedBox(height:  10),
        CountDownWidget()
      ],
    );
  }
}