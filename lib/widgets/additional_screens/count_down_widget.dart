import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/lang.dart';
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
      Helper.viewSnackBar(context: context, text: Lang.text('Таймер завершился!'), icon: const Icon(Icons.lock_clock, color: AppStyle.mainColor));
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
            titlePadding: const EdgeInsets.all(0),
            title: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppStyle.greyColor, size: 38)
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(Lang.text('Установите обратный таймер'), style: const TextStyle(fontSize: 16)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextField(
                    enableInteractiveSelection: false,
                    cursorColor: AppStyle.mainColor,
                    style: const TextStyle(color: AppStyle.mainColor),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppStyle.mainColor, width: 2)
                      ),
                      hintText: '00:00:00'
                    ),
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
                        child: Text(e, style: const TextStyle(
                          decoration: TextDecoration.underline, 
                          color: AppStyle.mainColor,
                          fontSize: 17
                        ))
                      )).toList()
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
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: AppStyle.decorMainContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Lang.text('Обратный таймер'), style: const TextStyle(fontSize: 18)),
          Flexible(
            flex: 2,
            child: InkResponse(
              onTap: _dialogSetTimer,
              child: CircularCountDownTimer(
                strokeCap: StrokeCap.round,
                strokeWidth: 15,
                //key: UniqueKey(),
                textFormat: CountdownTextFormat.HH_MM_SS,
                duration: _durationCircular,
                isReverse: true,
                controller: _controller,
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.height * 0.45,
                textStyle: const TextStyle(fontSize: 26),
                ringColor: Colors.white,
                fillColor: AppStyle.mainColor,
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: buildButtons(),
            ),
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
        _isRunning
        ? InkResponse(
          onTap: () => _stopTimer(reset: false),
          child: AppStyle.getButton(color: AppStyle.colorButtonOrange, text: Lang.text('Пауза')),
        )
        : InkResponse(
          onTap: () => _resumeTimer(),
          child: AppStyle.getButton(color: AppStyle.colorButtonBlue, text: Lang.text('Продолж.')),
        ),
        const SizedBox(width: 20),
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