import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/permissions.dart';
import 'package:thermo/components/styles.dart';
import 'package:thermo/observers/observer_app_lifecycle.dart';
import 'package:thermo/observers/observer_battery_charge.dart';
import 'package:thermo/observers/observer_bluetooth_scaner.dart';
import 'package:thermo/observers/observer_device_scaner.dart';
import 'package:thermo/widgets/additional_screens/faq_widget.dart';
import 'package:thermo/widgets/additional_screens/settings_widget.dart';
import 'package:thermo/widgets/main_screen/main_widget.dart';

class InitWidget extends StatefulWidget {
  const InitWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<InitWidget> createState() => _InitWidgetState();
}

class _InitWidgetState extends State<InitWidget> {
  final ObserverAppLifecycle _lifecycleObserver = ObserverAppLifecycle();
  
  int _selectedTab = 0;
  bool _tabChangedBySwipe = false;

  bool? bluetoothOn;
  bool? sensorOn;

  StreamSubscription<bool>? statusSensorSubscription;

  void onSelectTab(int index) {
    if (_selectedTab == index) return;

    setState(() {
      _selectedTab = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
    ObserverBatteryCharge.changeBatteryCharge ??= () { setState(() {}); };
    _lifecycleObserver.addLifecycleObserver();
  }

  @override
  void dispose() {
    ObserverBluetoothScaner.bluetoothStatusChanged = null;
    ObserverBatteryCharge.changeBatteryCharge = null;
    statusSensorSubscription?.cancel();
    _lifecycleObserver.removeLifecycleObserver();
    super.dispose();
  }

  Future<bool> _init() async {
    if (await DevicePermissions.checkPermissions() == false) {
      bluetoothOn = false;
      setState(() {});
    } else {
      ObserverDeviceScaner();
      ObserverBluetoothScaner();

      ObserverBluetoothScaner.bluetoothStatusChanged ??= _bluetoothStatusChanged;
      statusSensorSubscription = ApiBluetooth.statusSensorStream.listen((bool statusSensor){
        if (sensorOn == statusSensor) return;
        sensorOn = statusSensor;
        setState(() {});
        Future.delayed(const Duration(seconds: 1), () => ObserverBatteryCharge());
      });
    }

    return true;
  }

  void _bluetoothStatusChanged() {
    if (bluetoothOn == ApiBluetooth.statusBluetooth) return;
    bluetoothOn = ApiBluetooth.statusBluetooth;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dy.abs() > 5) return; //исключить случайный свайп при скроллинге
        if (_tabChangedBySwipe) return; //чтобы не проскакивало сразу с 1 вкладки на 3 и наоборот

        if (details.delta.dx > 3 && _selectedTab > 0) {
          onSelectTab(_selectedTab - 1);
          _tabChangedBySwipe = true;
        }
        if (details.delta.dx < -3 && _selectedTab < 2) {
          onSelectTab(_selectedTab + 1);
          _tabChangedBySwipe = true;
        }
      },
      onPanEnd: (details) => _tabChangedBySwipe = false, //сброс флага
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.045),
          child: AppBar(
            backgroundColor: AppStyle.barColor,
            actions: [
              AppStyle.getIconBluetooth(bluetoothOn),
              const SizedBox(width: 20),
              AppStyle.getIconSensor(sensorOn),
              const SizedBox(width: 20),
              Visibility(
                visible: ObserverBatteryCharge.charge != null,
                child: Center(child: Text('${ObserverBatteryCharge.charge}%', style: const TextStyle(color: Colors.white, fontSize: 13)))
              ),
              AppStyle.getIconBattery(ObserverBatteryCharge.charge),  
              const SizedBox(width: 10),
            ]
          ),
        ),
        body: IndexedStack(
          index: _selectedTab,
          children: const [
            MainScreenWidget(),
            SettingsWidget(),
            FaqWidget(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          //iconSize: 24,
          currentIndex: _selectedTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.question_mark),
              label: '',
            ),
          ],
          onTap: onSelectTab,
        ),
      ),
    );
  }
}