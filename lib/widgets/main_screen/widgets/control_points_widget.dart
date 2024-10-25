import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:thermo/components/adaptive.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/notifier.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';
import 'package:provider/provider.dart';
import 'package:thermo/main.dart';
import 'package:thermo/widgets/assets.dart';
import 'package:vibration/vibration.dart';

class _ViewModel extends ChangeNotifier {
  final TextEditingController _controlPointsTextController = TextEditingController();
  StreamSubscription<double>? temperatureSubscription;
  double? _previousTemperature;
  final List<bool> notifiedPoints = [false,false,false,false];

  Future<bool>? isDone;
  final _dataProvider = DataProvider();
  final _player = AudioPlayer();
  late List<dynamic> controlPoints;
  bool updateControlPoints = false;

  _ViewModel() {
    isDone = _setup();
  }

  Future<bool> _setup() async {
    controlPoints = await _dataProvider.getControlPoints();
    temperatureSubscription = ApiBluetooth.temperatureStream.listen((double temperature) => _checkTemperature(temperature));
    return true;
  }

  //проверяем достигла ли температура какой-либо контрольной точки. Если да - уведомляем. Аудио / вибрация
  void _checkTemperature(double temperature) {
    if (_previousTemperature == null) {
      _previousTemperature = temperature;
      return;
    }
    
    bool needUpdateWidget = false;
    for (final (key, point) in controlPoints.indexed) {
      bool reached = false;
      if (notifiedPoints[key] == true) continue;

      if (temperature > _previousTemperature!) {
        if (point['value'] >= _previousTemperature && point['value'] <= temperature) reached = true;
      } else {
        if (point['value'] >= temperature && point['value'] <= _previousTemperature) reached = true;
      }
      if (reached == true) {
        if (point['notify'] == Settings.typeNone) {
          needUpdateWidget = true;
          notifiedPoints[key] = true;
        } else {
          _alert(key: key, point: point);
        }
      }
    }
    _previousTemperature = temperature;
    if (needUpdateWidget == true) {
      updateControlPoints = !updateControlPoints;
      notifyListeners();
    }
  }

  Future<void> _alert({required int key, required dynamic point}) async {
    if (Navigator.of(navigatorKey.currentState!.context).canPop()) return;
    /*if (Navigator.of(navigatorKey.currentState!.context).canPop()) {
      Navigator.of(navigatorKey.currentState!.context).pop();
      if (point['notify'] == Settings.typeRing) await _player.stop();
    }*/

    if (point['notify'] == Settings.typeVibration) Vibration.vibrate(duration: 5000);
    if (point['notify'] == Settings.typeRing) _player.play(AssetSource('../${AppAssets.alarmAudioLong}'));

    // ignore: use_build_context_synchronously
    Helper.alert(
      choice: true,
      title: Lang.text('Уведомление'),
      context: navigatorKey.currentState!.context, 
      content: Lang.text('Контрольная точка в %s пройдена', ['${point['value']}${Helper.celsius}']), 
      cancelText: Lang.text('Не следить'),
      confirmText: Lang.text('Продолжить'),
      closeAction: () {
        Navigator.of(navigatorKey.currentState!.context).pop();
        _player.stop();
      },
      confirmAction: () {
        Navigator.of(navigatorKey.currentState!.context).pop();
        _player.stop();
      },
      cancelAction: () {
        Navigator.of(navigatorKey.currentState!.context).pop();
        _player.stop();
        notifiedPoints[key] = true;
        updateControlPoints = !updateControlPoints;
        notifyListeners();
      }
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void changeNotify(int indexPoint) async {
    controlPoints[indexPoint]['notify'] = Settings.changeTypeNotify(controlPoints[indexPoint]['notify']);
    _dataProvider.setControlPoints(controlPoints);
    updateControlPoints = !updateControlPoints;
    notifyListeners();
  }

  changeTemperature(BuildContext context, int indexPoint) {
    _controlPointsTextController.text = controlPoints[indexPoint]['value'].toString();
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
                Text(Lang.text('Укажите температуру контрольной точки'), style: const TextStyle(fontSize: 15)),
                TextFormField(
                  controller: _controlPointsTextController,
                  enableInteractiveSelection: false,
                  cursorColor: AppStyle.mainColor,
                  style: const TextStyle(color: AppStyle.mainColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppStyle.mainColor, width: 2)
                    ),
                    hintText: "50.0 ${Helper.celsius}"
                  ),
                  inputFormatters: [MaskTextInputFormatter(mask: '##.#', filter: { '#': RegExp(r'[0-9]') })],
                  //initialValue: controlPoints[indexPoint]['value'].toString(),
                  autofocus: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (value) {
                    _changeTemp(indexPoint, value);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10) 
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: AppStyle.getButtonCancel(text: Lang.text('Отмена'))
                  ),
                  InkWell(
                    onTap: () {
                      _changeTemp(indexPoint, _controlPointsTextController.text);
                      Navigator.of(context).pop();
                    },
                    child: AppStyle.getButton(color: AppStyle.colorButtonGreen, text: 'OK')
                  ),
                ],
              )
            ],
          )
        );
      },
    );
  }

  void _changeTemp(int indexPoint, String value) {
    if (value == '') return;
    controlPoints[indexPoint]['value'] = double.parse(value);
    _dataProvider.setControlPoints(controlPoints);
    notifiedPoints[indexPoint] = false;
    updateControlPoints = !updateControlPoints;
    notifyListeners();
  }
}

class ControlPointsWidget extends StatelessWidget {
  const ControlPointsWidget({Key? key}) : super(key: key);

  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => _ViewModel(),
      child: const ControlPointsWidget(),
    );
  }


  @override
  Widget build(BuildContext context) {
    final model = context.read<_ViewModel>();

    return FutureBuilder<void>(
      future: model.isDone, 
      builder: (context, snapshot) {
        return snapshot.connectionState == ConnectionState.waiting
          ? Helper.loader
          : Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: AppStyle.decorMainContainer,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: 
                      model.controlPoints.map((point) =>
                      _Row(point: point)).toList(),
                    )
                  ),
                ],
            ),
          );
      }
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.point });

  final dynamic point;

  @override
  Widget build(BuildContext context) {
    final model = context.read<_ViewModel>();
    context.select((_ViewModel model) => model.updateControlPoints);
    
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Adaptive.padding(10, context)),
        child: Row(
          //mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: InkWell(
                onTap: () => model.changeTemperature(context, model.controlPoints.indexOf(point)),
                borderRadius: BorderRadius.circular(10),
                child: Align(alignment: Alignment.centerRight,
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: TextStyle(
                        //decoration: TextDecoration.underline,
                        color: model.notifiedPoints[model.controlPoints.indexOf(point)] == true ? AppStyle.mainColor : Colors.black,
                        fontWeight: model.notifiedPoints[model.controlPoints.indexOf(point)] == true ? FontWeight.bold : FontWeight.normal,
                      ),
                      children: [
                        TextSpan(text: point['value'].toString(), style: TextStyle(fontSize: Adaptive.text(18, context))),
                        TextSpan(text: Helper.celsius, style: TextStyle(fontSize: Adaptive.text(14, context))),
                      ]
                    ),
                  )
                ),
              ),
            ),
            const Flexible(flex: 1, child: SizedBox()),
            Flexible(
              flex: 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => model.changeNotify(model.controlPoints.indexOf(point)),
                child: Center(child: Notifier.getNotifyIcon(type: point['notify']!, context: context,
                  color: model.notifiedPoints[model.controlPoints.indexOf(point)] == true ? AppStyle.mainColor : Colors.black)
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}