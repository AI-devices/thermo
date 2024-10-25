abstract class Lang {
  static const bool ru = false;

  static String text(String text, [List<dynamic>? vars]) {
    if (ru == false) text = _rusToEng[text]!;
    if (vars == null) return text;
    for (var arg in vars) {
      text = text.replaceFirst('%s', arg.toString());
    }
    return text;
  }

  static const Map<String, String> _rusToEng = {
    'Нет' : 'No',
    'Да' : 'Yes',
    'Таймер' : 'Timer',
    'Главный' : 'Main',
    'Настройки' : 'Settings',
    'Предупреждение' : 'Warning',
    'Уведомление' : 'Notification',
    'Температура падает' : 'The temperature is dropping',
    'Отмена' : 'Cancel',
    'Стоп' : 'Stop',
    'Начать' : 'Start',
    'Старт' : 'Start',
    'Сбросить' : 'Reset',
    'Пауза' : 'Pause',
    'Не следить' : 'Not to follow',
    'Продолжить' : 'Continue',
    'Продолж.' : 'Continue',
    'Данный девайс не поддерживает Bluetooth' : 'This device does not support Bluetooth',
    'Нет соединения с Bluetooth' : 'No Bluetooth connection',
    'Термодатчик не обнаружен. Убедитесь, что он включен' : 'Temperature sensor is not detected. Make sure it is turned on',
    'Потеряно соединение с термодатчиком' : 'Lost connection to temperature sensor',
    'Пройдена контрольная точка' : 'Checkpoint passed',
    'Доступ к bluetooth запрещен. Установить соединение с датчиком невозможно' : 'Bluetooth access is denied. Cannot connect to the sensor',
    'Включите передачу локации. Без этого bluetooth работать не будет' : 'Enable location transfer. Bluetooth will not work without it',
    'Доступ к локации запрещен. Без этого bluetooth работать не будет' : 'Access to the location is denied. Bluetooth will not work without it',
    'Низкий заряд батареи (%s%)' : 'Low battery (%s%)',
    'мин.' : 'min.',
    'сек.' : 'sec.',
    'ч.' : 'h.',
    'Достигнуто минимальное значение калибровки' : 'The minimum calibration value has been reached',
    'Достигнуто максимальное значение калибровки' : 'The maximum calibration value has been reached',
    'Укажите процент заряда датчика для уведомления' : 'Specify the sensor charge percentage for notification',
    'Максимальный масштаб статистики (%s ч.)' : 'The maximum scale of statistics (%s h.)',
    'Сигнал при падении температуры в течение 5 секунд' : 'Signal when the temperature drops within 5 seconds',
    'Сигнал при завершении таймера' : 'Signal at timer end',
    'Калибровка датчика' : 'Sensor calibration',
    'Пояснение' : 'Explanation',
    'Повышает или снижает показания датчика в приложении на указанное значение. Показания на экране датчика не корректируются.' : 'Increases or decreases the sensor reading in the application by the specified value. The reading on the sensor screen is not corrected.',
    'Cкрыть автоматический расчет спиртуозности' : 'Hide the automatic calc of alcohol content',
    'Приблизительный расчет спиртуозности в кубе и в отборе по температуре при нагреве в перегонном кубе. Диапазон температуры от 79 до 99 градусов.' : 'Approximate calculation of alcohol content in the cube and in the selection by temperature when heated in the distilling cube. The temperature range is 79 to 99 degrees Celsius.',
    'Предупреждение при низком заряде датчика (<%s%)' : 'Warning when sensor power is low (<%s%)',
    'Предупреждение при потере сигнала от датчика' : 'Warning when sensor signal is lost',
    'Не давать засыпать телефону' : 'Not to let the phone go to sleep',
    'Нет подключения к датчику' : 'No connection to the sensor',
    'Текущая статистика вышла за диапазон одного часа. Уменьшить масштаб нельзя.' : 'The current statistics have exceeded the one-hour range. It is not possible to zoom out.',
    'График температуры' : 'Temperature chart',
    'Контрольная точка в %s пройдена': 'The checkpoint in %s is passed.', 
    'Укажите температуру контрольной точки' : 'Specify the checkpoint temperature',
    'Таймер завершился!' : 'The timer has ended!',
    'Обратный таймер' : 'Countdown timer',
    'Установите обратный таймер' : 'Set a countdown timer',
    'Ожидается подключение к датчику' : 'Connection to the sensor is pending',
    'Спиртуозность, %AC' : 'Alcohol content, %AC',
    'Диапазон от 79 до 99 градусов' : 'Range from 79 to 99 degrees',
    'Показать спиртуозность' : 'Show alcohol content',
    'в кубе: ' : 'in the still: ',
    'в отборе: ' : 'body collectIon: ',
    'температура датчика: %s' : 'sensor temperature: %s',
    'У приложения нет доступа к отправке уведомлений. Вы можете дать разрешение в настройках. Хотите это сделать?' : 'The application does not have access to send notifications. You can give permission in settings. Do you want to do this?',
    'Отображение температуры в фоновом режиме приложения' : 'Displaying temperature in the background of the application',
  };
}