import 'dart:async';
import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/settings.dart';

mixin ApiBluetoothV2 {
  static int? batteryCharge;
  static DateTime lastHandledDatetime = DateTime(1970, 1, 1);

  void readDataV2(ScanResult r) {
    if (ApiBluetooth.version == ApiBluetoothVersion.version1oldSensor || ApiBluetooth.version == ApiBluetoothVersion.version1newSensor) return;

    //если условие выполняется - считаем, что соединение с датчиком потеряно. Условие перенесено в метод listenConnectV2()
    /*if (DateTime.now().difference(r.timeStamp).inSeconds > 15) {
      if (ApiBluetooth.statusSensor == true) (this as ApiBluetooth).dissconnect();
      return;
    }*/

    if (ApiBluetooth.version == ApiBluetoothVersion.unknown) {
      ApiBluetooth.version = ApiBluetoothVersion.version2;
      log(r.toString(), name: ApiBluetooth.version.toString());
      if (!Settings.remoteIds.contains(r.device.remoteId.toString())) Settings.remoteIds.add(r.device.remoteId.toString());
    }

    if (r.timeStamp.difference(lastHandledDatetime).inSeconds <= 1) return; //считываем данные раз в секунду, тут сыпится очень много дублей
    lastHandledDatetime = r.timeStamp;

    List<int>? dataInBytes = r.advertisementData.serviceData[r.advertisementData.serviceData.keys.first];
    if (dataInBytes == null || dataInBytes.length != 6) return;

    if (ApiBluetooth.statusSensor == false) {
      ApiBluetooth.statusSensor = true;
      ApiBluetooth.controllerStatusSensor.add(true);
      (this as ApiBluetooth).prevAlarmSensorDissconnectedClose();
      //Notifier.snackBar(notify: Notify.sensorConnected);
    }

    /**
     * пример dataInBytes : [64,2,54,11,1,87]
     * 64 (0x40) ничего не значит или какой-то скрытый смысл
     * 2  (0x02) следующие два байта указывают на температуру
     * 54 (0x36) low byte
     * 11 (0xb)  high byte
     * 1  (0x01) следующий один байт указывает на заряд батареи
     * 87 (0x57) заряд батареи
     */
    ApiBluetooth.controllerTemperature.add(Helper.parseTemperature([dataInBytes[2], dataInBytes[3]]));
    batteryCharge = dataInBytes[5];
  }

  void dissconnectToSensorV2() {
    ApiBluetooth.statusSensor = false;
    ApiBluetooth.controllerStatusSensor.add(false);
    (this as ApiBluetooth).alarmSensorDissconnected();
  }

  void switchOffV2() {}

  void switchOnV2() {
    ApiBluetooth.version = ApiBluetoothVersion.version2;
    log('switch to ${ApiBluetooth.version}');
    FlutterBluePlus.startScan(withRemoteIds: Settings.remoteIds);
  }

  void listenConnectV2() async {
    Timer.periodic(const Duration(seconds: 30), (Timer timer) async {
      if (ApiBluetooth.statusSensor == false) return;
      if (ApiBluetooth.version != ApiBluetoothVersion.version2) return;
      
      await Future.delayed(const Duration(seconds: 25)); //25 сек успеть получить первую температуру по 2 версии при переключении с 1 версии
      if (DateTime.now().difference(lastHandledDatetime).inSeconds > 60) { //бывают большие перерывы между считываниями адвертайзов
        (this as ApiBluetooth).dissconnect();
      }
    });
  }
}