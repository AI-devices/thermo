import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/api_vibration.dart';
import 'package:thermo/components/styles.dart';
import 'package:thermo/observers/app_lifecycle_observer.dart';
import 'package:thermo/observers/observer_battery_charge.dart';
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
  final AppLifecycleObserver _lifecycleObserver = AppLifecycleObserver();
  
  int _selectedTab = 0;

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
    ApiBluetooth.bluetoothStatusChanged = null;
    ObserverBatteryCharge.changeBatteryCharge = null;
    statusSensorSubscription?.cancel();
    _lifecycleObserver.removeLifecycleObserver();
    super.dispose();
  }

  Future<bool> _init() async {
    if (await ApiBluetooth.isSupported() == false) {
      bluetoothOn = false;
      setState(() {});
    } else {
      ApiBluetooth();
      ApiBluetooth.bluetoothStatusChanged ??= _bluetoothStatusChanged;
      statusSensorSubscription = ApiBluetooth.statusSensorStream.listen((bool statusSensor){
        if (sensorOn == statusSensor) return;
        sensorOn = statusSensor;
        setState(() {});
        Future.delayed(const Duration(seconds: 1), () => ObserverBatteryCharge());
      });
    }
    await ApiVibration.isSupported();

    return true;
  }

  void _bluetoothStatusChanged() {
    if (bluetoothOn == ApiBluetooth.statusBluetooth) return;
    bluetoothOn = ApiBluetooth.statusBluetooth;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}