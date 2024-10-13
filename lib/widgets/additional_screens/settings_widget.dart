import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thermo/components/adaptive.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/local_notification.dart';
import 'package:thermo/components/notifier.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  StreamSubscription<void>? hidePercentSpiritWidgetSubscription;
  final _dataProvider = DataProvider();
  final TextEditingController _lowBatteryChargeTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Settings.notifyWhenTempDropsChanged ??= () => setState(() {});
    hidePercentSpiritWidgetSubscription = Settings.hidePercentSpiritWidgetStream.listen((_){
      setState(() {});
    });
    _lowBatteryChargeTextController.text = Settings.alarmLowBatteryCharge['percent_charge'];
  }

  @override
  void dispose() {
    hidePercentSpiritWidgetSubscription?.cancel();
    super.dispose();
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

  void changeCalibrationSensor({required String action}) {
    if (action == 'sub') {
      if (Settings.calibrationSensor <= -5.0) {
        Helper.alert(context: context, content: Lang.text('Достигнуто минимальное значение калибровки'));
        return;
      }
      Settings.calibrationSensor = double.parse((Settings.calibrationSensor - 0.1).toStringAsFixed(1));
    } else {
      if (Settings.calibrationSensor >= 5.0) {
        Helper.alert(context: context, content: Lang.text('Достигнуто максимальное значение калибровки'));
        return;
      }
      Settings.calibrationSensor = double.parse((Settings.calibrationSensor + 0.1).toStringAsFixed(1));
    }
    _dataProvider.setCalibrationSensor();
    setState(() {});
  }

  void changeVisibilityPercentSpiritWidget() {
    Settings.hidePercentSpiritWidget = !Settings.hidePercentSpiritWidget;
    _dataProvider.setHidePercentSpiritWidget();
    Settings.controllerHidePercentSpiritWidget.add(null);
  }

  changeNotifyAlarmLowBatteryCharge(bool value) {
    if (value == false) {
      _setAlarmLowBatteryCharge(on: value);
    } else {
      return showDialog<dynamic>(
        barrierDismissible: false,
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
                  Text(Lang.text('Укажите процент заряда датчика для уведомления')),
                  TextFormField(
                    controller: _lowBatteryChargeTextController,
                    cursorColor: AppStyle.mainColor,
                    style: const TextStyle(color: AppStyle.mainColor),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2)
                    ],
                    enableInteractiveSelection: false,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppStyle.mainColor, width: 2)
                      ),
                      hintText: "20 %"
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (value != '') _setAlarmLowBatteryCharge(on: true);
                    },
                  )
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10) 
              ),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (_lowBatteryChargeTextController.text != '') _setAlarmLowBatteryCharge(on: true);
                  },
                  child: AppStyle.getButton(color: AppStyle.colorButtonGreen, text: 'OK')
                ),
              ],
            )
          );
        },
      );
    }
  }

  _setAlarmLowBatteryCharge({required bool on}) {
    Settings.alarmLowBatteryCharge['on'] = on;
    if (Settings.alarmLowBatteryCharge['on'] == true) {
      Settings.alarmLowBatteryCharge['percent_charge'] = _lowBatteryChargeTextController.text;
    }
    _dataProvider.setAlarmLowBatteryCharge();
    setState(() {});
  }

  void changeWakelock(bool value) {
    Settings.wakelock = value;
    _dataProvider.setWakelock();
    value == true ? WakelockPlus.enable() : WakelockPlus.disable();
    setState(() {});
  }

  void changeAlarmSensorDissconnected() {
    Settings.alarmSensorDissconnected = !Settings.alarmSensorDissconnected;
    _dataProvider.setAlarmSensorDissconnected();
    setState(() {});
  }

  void changeLocalNotifications(bool value) async {
    if (value == true && Settings.notificationIsEnabled == false) {
      return Helper.alert(
        choice: true,
        context: context, 
        content: Lang.text('У приложения нет доступа к отправке уведомлений. Вы можете дать разрешение в настройках. Хотите это сделать?'), 
        confirmAction: () {
          Navigator.of(context).pop();
          openAppSettings();
        }, 
      );
    }
    Settings.allowLocalNotifications = value;
    if (Settings.allowLocalNotifications == false) await LocalNotification.cancelNotifications();
    _dataProvider.setAllowLocalNotifications();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(Lang.text('Настройки'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
            ),
            _notifyWhenTempDrops(),
            _notifyWhenTimerEnds(),
            _calibrationSensor(),
            _percentSpirit(),
            _alarmLowBatteryCharge(),
            _wakelock(),
            _alarmSensorDissconnected(),
            _localNotifications(),
          ],
        ),
      ),
    );
  }

  Padding _notifyWhenTempDrops() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: AppStyle.decorMainContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(flex: 7, child: Text(Lang.text('Сигнал при падении температуры в течение 5 секунд'), style: TextStyle(fontSize: Adaptive.text(14, context)))),
            Flexible(
              flex: 4, 
              child: Container(
                height: double.infinity,
                width: 50,
                decoration: AppStyle.decorMainContainer,
                child: IconButton(
                  icon: Notifier.getNotifyIcon(type: Settings.notifyWhenTempDrops, context: context), 
                  onPressed: changeNotifyWhenTempDrops,
                ),
              )
            ),
            
          ],
        ),
      ),
    );
  }

  Padding _notifyWhenTimerEnds() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: AppStyle.decorMainContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(flex: 6, child: Text(Lang.text('Сигнал при завершении таймера'), style: TextStyle(fontSize: Adaptive.text(14, context)))),
            Flexible(
              flex: 4, 
              child: Container(
                height: double.infinity,
                width: 50,
                decoration: AppStyle.decorMainContainer,
                child: IconButton(
                  icon: Notifier.getNotifyIcon(type: Settings.notifyWhenTimerEnds, context: context), 
                  onPressed: changeNotifyWhenTimerEnds,
                ),
              )
            ),
            
          ],
        ),
      ),
    );
  }

  Padding _calibrationSensor() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: AppStyle.decorMainContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(flex: 2, child: Text(Lang.text('Калибровка датчика'), style: TextStyle(fontSize: Adaptive.text(14, context)))),
            Flexible(
              flex: 1,
              child: IconButton(
                onPressed: () => Helper.alert(context: context, title: Lang.text('Пояснение'), content: Lang.text('Повышает или снижает показания датчика в приложении на указанное значение. Показания на экране датчика не корректируются.')),
                icon: Icon(Icons.help_outline, color: AppStyle.greyColor, size: Adaptive.icon(30, context))
              ),
            ),
            Flexible(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 43,
                    width: 43,
                    decoration: AppStyle.decorMainContainer,
                    child: IconButton(
                      icon: const Icon(Icons.remove), 
                      onPressed: () => changeCalibrationSensor(action: 'sub'),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.height * 0.01),
                  Container(
                    height: 43,
                    width: MediaQuery.of(context).size.width * 0.12,
                    decoration: AppStyle.decorMainCotnainerInset,
                    child: Center(
                      child: Text(
                        Settings.calibrationSensor.toString(), 
                        textAlign: TextAlign.right, 
                        style: const TextStyle(fontSize: 18)
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.height * 0.01),
                  Container(
                    height: 43,
                    width: 43,
                    decoration: AppStyle.decorMainContainer,
                    child: IconButton(
                      icon: const Icon(Icons.add), 
                      onPressed: () => changeCalibrationSensor(action: 'add'),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  Padding _percentSpirit() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: AppStyle.decorMainContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(child: Text(Lang.text('Cкрыть автоматический расчет спиртуозности'), style: TextStyle(fontSize: Adaptive.text(14, context)))),
                  IconButton(
                    onPressed: () => Helper.alert(context: context, title: Lang.text('Пояснение'), content: Lang.text('Приблизительный расчет спиртуозности в кубе и в отборе по температуре при нагреве в перегонном кубе. Диапазон температуры от 79 до 99 градусов.')),
                    icon: Icon(Icons.help_outline, color: AppStyle.greyColor, size: Adaptive.icon(30, context))
                  )
                ],
              )
            ),
            Flexible(
              flex: 4, 
              child: Helper.switcher(value: Settings.hidePercentSpiritWidget, action: (_) => changeVisibilityPercentSpiritWidget())
            ),
            
          ],
        ),
      ),
    );
  }

  Padding _alarmLowBatteryCharge() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: AppStyle.decorMainContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 6,
              child: Text(Lang.text('Предупреждение при низком заряде датчика (<%s%)', [Settings.alarmLowBatteryCharge['percent_charge']]),
                style: TextStyle(fontSize: Adaptive.text(14, context))
              )
            ),
            Flexible(
              flex: 4, 
              child: Helper.switcher(value: Settings.alarmLowBatteryCharge['on'] as bool, action: (value) => changeNotifyAlarmLowBatteryCharge(value))
            ),
          ],
        ),
      ),
    );
  }

  Padding _wakelock() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: AppStyle.decorMainContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(flex: 6, child: Text(Lang.text('Не давать засыпать телефону'), style: TextStyle(fontSize: Adaptive.text(14, context)))),
            Flexible(
              flex: 4, 
              child: Helper.switcher(value: Settings.wakelock, action: (value) => changeWakelock(value))
            ),
          ],
        ),
      ),
    );
  }

  Padding _alarmSensorDissconnected() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: AppStyle.decorMainContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(flex: 6, child: Text(Lang.text('Предупреждение при потере сигнала от датчика'), style: TextStyle(fontSize: Adaptive.text(14, context)))),
            Flexible(
              flex: 4, 
              child: Helper.switcher(value: Settings.alarmSensorDissconnected, action: (_) => changeAlarmSensorDissconnected())
            ),
          ],
        ),
      ),
    );
  }

  Padding _localNotifications() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: AppStyle.decorMainContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(flex: 6, child: Text(Lang.text('Отображение температуры в фоновом режиме приложения'), style: TextStyle(fontSize: Adaptive.text(14, context)))),
            Flexible(
              flex: 4, 
              child: Helper.switcher(value: Settings.allowLocalNotifications, action: (value) => changeLocalNotifications(value))
            ),
          ],
        ),
      ),
    );
  }
}