import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth.dart';
import 'package:thermo/components/api_vibration.dart';
import 'package:thermo/components/styles.dart';
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
  int _selectedTab = 0;

  bool? bluetoothOn;
  bool? sensorOn;
  int? batteryCharge;

  StreamSubscription<bool>? statusSensorSubscription;

  void onSelectTab(int index) {
    if (_selectedTab == index) return;

    setState(() {
      _selectedTab = index;
    });
  }

  @override
  void initState() {
    _init();
    _timerCheckBatteryCharge();
    super.initState();
  }

  @override
  void dispose() {
    ApiBluetooth.bluetoothStatusChanged = null;
    statusSensorSubscription?.cancel();
    super.dispose();
  }

  void _timerCheckBatteryCharge() {
    Timer.periodic(const Duration(minutes: 1), (_) async {
      await _checkBatteryCharge();
    });
  }

  Future<void> _checkBatteryCharge() async {
    if (sensorOn == false) {
      if (batteryCharge == null) return;
      batteryCharge = null;
      setState(() {});
      return;
    }
    final currentCharge = await ApiBluetooth.getBatteryCharge();
    if (currentCharge != batteryCharge) {
      batteryCharge = currentCharge;
      setState(() {});
    }
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
        Future.delayed(const Duration(seconds: 1), () => _checkBatteryCharge());
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
              visible: batteryCharge != null,
              child: Center(child: Text('$batteryCharge%', style: const TextStyle(color: Colors.white, fontSize: 13)))
            ),
            AppStyle.getIconBattery(batteryCharge),  
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