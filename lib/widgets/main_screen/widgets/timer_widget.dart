import 'dart:async';
import 'package:flutter/material.dart';
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
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: AppStyle.decorMainCotnainers,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Center(child: buildTime())
          ),
          Flexible(
            flex: 1,
            child: buildButtons()
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
    return Center(child: Text('$hours:$minutes:$seconds', style: const TextStyle(fontSize: 20)));
  }

  Widget buildButtons() {
    final isRunning = _timer != null && _timer!.isActive;

    return isRunning || duration.inSeconds != 0
      ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: MaterialButton(
                height: 32.0, 
                minWidth: 70.0, 
                color: isRunning ? Colors.black : Colors.green, 
                textColor: Colors.white,
                onPressed: () => isRunning ? _stopTimer(reset: false) : _startTimer(), 
                child: isRunning ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MaterialButton( 
                height: 32.0, 
                minWidth: 70.0, 
                color: Colors.red, 
                textColor: Colors.white, 
                onPressed: () => _stopTimer(reset: true),
                child: const Icon(Icons.stop), 
              ),
            ),
          ],
        )

      : MaterialButton( 
          height: 32.0, 
          minWidth: 70.0, 
          color: Colors.green, 
          textColor: Colors.white, 
          onPressed: _startTimer, 
          child: const Icon(Icons.play_arrow), 
        );
  }
}