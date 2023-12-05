import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';
import 'package:thermo/widgets/assets.dart';
import 'package:vibration/vibration.dart';

class CountDownWidget extends StatefulWidget {
  const CountDownWidget({Key? key}) : super(key: key);

  @override
  State<CountDownWidget> createState() => __CountDownWidgetState();
}

class __CountDownWidgetState extends State<CountDownWidget> {
  final _dataProvider = DataProvider();
  final _player = AudioPlayer();
  List<dynamic> lastTimers = [];
  bool _isRunning = false;
  bool _isPause = false;

  int _durationCircular = 0;

  int _durationNotify = 0;
  Timer? _timer; //? нужен для вибрировании по истечении основного таймера из-за того, что в фоне событие onComplete() не отрабатывает

  final CountDownController _controller = CountDownController();

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _init() async {
    lastTimers = await _dataProvider.getLastTimers();
  }

  void _setTimer(String value) {
    _durationCircular = Helper.getDurationInSeconds(value);
    _restartTimer();
    if (lastTimers.contains(value)) return;

    if (lastTimers.length >= 3) lastTimers.removeAt(0);
    lastTimers.add(value);
    _dataProvider.saveLastTimers(lastTimers);
    setState(() {});
  }

  void _stopTimer({required bool reset}) {
    _isRunning = false;
    if (reset) {
      _durationCircular = 0;
      _controller.restart(duration: _durationCircular);
      _isPause = false;

      _durationNotify = 0;
      _timer?.cancel();
    } else {
      _isPause = true;
      _controller.pause();
      _timer?.cancel();
      _durationNotify = Helper.getDurationInSeconds(_controller.getTime()!);
    }
    setState(() {});
  }

  void _startTimer() {
    if (_durationCircular == 0) {
      _dialogSetTimer();
      return;
    }
    _controller.start();
    _durationNotify = _durationCircular;
    _startNotifyTimer();
    _isRunning = true;
    _isPause = false;
    setState(() {});
  }

  void _restartTimer() {
    _controller.restart(duration: _durationCircular);
    _controller.pause();
  }

  void _resumeTimer() {
    _controller.resume();
    _startNotifyTimer();
    _isRunning = true;
    _isPause = false;
    setState(() {});
  }

  void _onCompleted() {
    if (_isRunning == true) {
      Helper.viewSnackBar(context: context, text: 'Таймер завершился!', icon: const Icon(Icons.lock_clock, color: Colors.green));
      _isRunning = false;
      setState(() {});
    }
  }

  void _startNotifyTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) { 
      _durationNotify -= 1;
      if (_durationNotify <= 0) {
        _timer?.cancel();
        if (Settings.notifyWhenTimerEnds == Settings.typeVibration) Vibration.vibrate(duration: 2000);
        if (Settings.notifyWhenTimerEnds == Settings.typeRing) {
          _player.play(AssetSource('../${AppAssets.alarmAudio}'), position: const Duration(seconds: 0));
        }
      }
    });
  }

  _dialogSetTimer() {
    if (_isRunning || _isPause) return;
    _stopTimer(reset: true);
    return showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Установите таймер'),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextField(
                    decoration: const InputDecoration(hintText: '00:00:00'),
                    //initialValue: '00:15:00',
                    autofocus: true,
                    inputFormatters: [MaskTextInputFormatter(mask: '##:##:##', filter: { '#': RegExp(r'[0-9]') })],
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.none,
                    onSubmitted: (_) => Navigator.of(context).pop(),
                    onChanged: (value) {
                      if (value.length == 8) {
                        _setTimer(value);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                Visibility(
                  visible: lastTimers.isNotEmpty,
                  child: Column(
                    children: lastTimers.map((e) => 
                      TextButton(
                        onPressed: () {
                          _setTimer(e);
                          Navigator.of(context).pop();
                        }, 
                        child: Text(e, style: const TextStyle(decoration: TextDecoration.underline)))).toList()
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10) 
            ),
          )
        );
      },
    );
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
            child: InkResponse(
              onTap: _dialogSetTimer,
              child: CircularCountDownTimer(
                //key: UniqueKey(),
                textFormat: CountdownTextFormat.HH_MM_SS,
                duration: _durationCircular,
                isReverse: true,
                controller: _controller,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                textStyle: const TextStyle(fontSize: 20),
                ringColor: Colors.grey[300]!,
                fillColor: Colors.green,
                autoStart: false,
                timeFormatterFunction: (defaultFormatterFunction, duration) {
                  if (duration.inSeconds == 0) {
                    //return "Start";
                    return "00:00:00";
                  } else {
                    return Function.apply(defaultFormatterFunction, [duration]);
                  }
                },
                onComplete: () => _onCompleted(), //в фоне не вызывается, только когда приложение снова выводится на передний план
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: buildButtons(),
          ),
        ],
      ),
    ); 
  }

  Widget buildButtons() {
    
    return _isRunning || _isPause
     ? Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Expanded(
           child: MaterialButton( 
             height: 32.0, 
             minWidth: 70.0, 
             color: _isRunning ? Colors.black : Colors.green, 
             textColor: Colors.white,
             onPressed: () => _isRunning ? _stopTimer(reset: false) : _resumeTimer(), 
             child: _isRunning ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
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