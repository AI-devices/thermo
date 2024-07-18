import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/notifier.dart';

mixin ApiBluetoothV2 {
  static const prefixDevice = 'ThermoD';
  static int? batteryCharge;
  static DateTime lastHandledDatetime = DateTime(1970, 1, 1);

  bool isOldData(DateTime timeStamp) {
    return DateTime.now().difference(timeStamp).inSeconds > 15;
  }

  void read(ScanResult r) {
    if (r.timeStamp.difference(lastHandledDatetime).inSeconds < 3) return; //очень много дублирующих ивентов поступает в одно и то же время. отсекаем
    lastHandledDatetime = r.timeStamp;

    List<int>? dataInBytes = r.advertisementData.serviceData[r.advertisementData.serviceData.keys.first];
    if (dataInBytes == null || dataInBytes.length != 6) return;

    if (ApiBluetooth.statusSensor == false) {
      ApiBluetooth.statusSensor = true;
      ApiBluetooth.controllerStatusSensor.add(true);
      (this as ApiBluetooth).prevAlarmSensorDissconnectedClose();
      Notifier.snackBar(notify: Notify.sensorConnected);
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
}