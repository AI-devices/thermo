import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/styles.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  State<TimerWidget> createState() => __TimerWidgetState();
}

class __TimerWidgetState extends State<TimerWidget> {
  Duration duration = const Duration();
  Timer? _timer;

  void _addTime() {
    setState(() {
      duration = Duration(seconds: duration.inSeconds + 1);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _addTime());
    setState(() {});
  }

  void _stopTimer({required bool reset}) {
    if (reset) duration = const Duration();
    _timer?.cancel();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: AppStyle.decorMainContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Lang.text('Таймер'), style: const TextStyle(fontSize: 18)),
          Flexible(
            flex: 2,
            child: Center(child: buildTime())
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: buildButtons(),
            )
          ),
        ],
      ),
    ); 
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours.remainder(60));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 5),
            Text(Lang.text('ч.'), style: const TextStyle(fontSize: 15, color: AppStyle.greyColor)),
            const SizedBox(width: 40),
            Text(Lang.text('мин.'), style: const TextStyle(fontSize: 15, color: AppStyle.greyColor)),
            const SizedBox(width: 30),
            Text(Lang.text('сек.'), style: const TextStyle(fontSize: 15, color: AppStyle.greyColor)),
          ],
        ),
        Center(
          child: Text('$hours:$minutes:$seconds', 
          style: const TextStyle(fontSize: 48))
        ),
      ],
    );
  }

  Widget buildButtons() {
    final isRunning = _timer != null && _timer!.isActive;

    return isRunning || duration.inSeconds != 0
      ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isRunning
          ? InkResponse(
            onTap: () => _stopTimer(reset: false),
            child: AppStyle.getButton(color: AppStyle.colorButtonOrange, text: Lang.text('Стоп')),
          )
          : InkResponse(
            onTap: () => _startTimer(),
            child: AppStyle.getButton(color: AppStyle.colorButtonBlue, text: Lang.text('Продолж.')),
          ),
          const SizedBox(width: 20
          ),
          InkResponse(
            onTap: () => _stopTimer(reset: true),
            child: AppStyle.getButton(color: AppStyle.colorButtonRed, text: Lang.text('Сбросить')),
          ),
        ],
      )
      : InkResponse(
        onTap: _startTimer,
        child: AppStyle.getButton(color: AppStyle.colorButtonGreen, text: Lang.text('Начать')),
      );
  }
}