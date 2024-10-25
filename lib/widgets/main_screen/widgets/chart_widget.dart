import 'dart:async';
import 'dart:developer';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:thermo/components/adaptive.dart';
import 'package:thermo/components/api_bluetooth/api_bluetooth.dart';
import 'package:thermo/components/data_provider.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/lang.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';

class ChartWidget extends StatefulWidget {
  const ChartWidget({super.key});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  final _dataProvider = DataProvider();
  double maxHoursForChart = Settings.maxHoursForChart.toDouble();
  
  final List<Color> gradientColors = [
    AppStyle.pinkColor.withOpacity(0.3),
    AppStyle.pinkColor.withOpacity(0.01),
  ];

  StreamSubscription<double>? _temperatureSubscription;
  double? _currentTemperature;
  List<FlSpot> coordinates = Settings.coordinatesChart;

  Timer? _timer;
  late Duration _duration;
  final int _interval = Settings.envDebug ? 5 : 60; //в тестах обновляем через 5 сек, на проде - через минуту

  double maxY = 10;
  double maxX = 15;
  double x = 0;
  double y = 0;
  
  late int maxHoursForStat;
  final double scaleXOneHour = 300; //1 деление - 5 мин (300 сек)
  late double scaleXManyHours; //зависит от настроек, вычисляется в _setAxisX()
  late double currentScaleX; //одно деление по оси X
  static const double _currentScaleY = 12.5; //одно деление по оси Y - 12.5 градусов

  @override
  void initState() {
    super.initState();
    currentScaleX = Settings.scaleAxisX;
    _duration = Duration(seconds: (coordinates.last.x * currentScaleX).toInt());
    _temperatureSubscription = ApiBluetooth.temperatureStream.listen((double temperature) => _currentTemperature = temperature);
    _setAxisX(init: true);

    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_duration.inSeconds != 0) Notifier.snackBar(notify: Notify.lastChartIsLoaded);
    });*/
  }

  void _setAxisX({required bool init}) {
    //если текущий график масштабирован до часов, которые только что изменили в настройках - надо перерисовать
    if (init == false && currentScaleX != scaleXOneHour) {
      coordinates = coordinates.map((e) {
        var newX = double.parse(((e.x * maxHoursForStat) / Settings.maxHoursForChart).toStringAsFixed(5));
        return newX > maxX ? FlSpot(maxX, e.y) : FlSpot(newX, e.y);
      }).toList();
      Settings.setCoordinatesChart(coordinates);
    }
    maxHoursForStat = Settings.maxHoursForChart;
    scaleXManyHours = (maxHoursForStat * 60 * 60) / 12; //переводим часы в секунды и делим на 12,т.к.на этой ячейке по оси X указано последнее значение
    if (currentScaleX != scaleXOneHour) {
      currentScaleX = scaleXManyHours;
      Settings.setScaleAxisX(scaleXManyHours);
    }
  }

  void drawChart() {
    x = double.parse((_duration.inSeconds / currentScaleX).toStringAsFixed(5));
    y = double.parse((_currentTemperature! / _currentScaleY).toStringAsFixed(5));

    FlSpot flSpot = FlSpot(x, y > maxY ? maxY : y);

    log(flSpot.props.toString(), name: 'flSpot');

    if (coordinates.length == 1 && coordinates[0].x == 0 && coordinates[0].y == 0) {
      coordinates = [flSpot];
    } else {
      coordinates.add(flSpot);
    }
    
    Settings.setCoordinatesChart(coordinates);
    setState(() {});
  }

  void _startTimer() {
    if (ApiBluetooth.statusSensor == false || _currentTemperature == null) {
      Helper.alert(context: context, content: Lang.text('Нет подключения к датчику'));
      return;
    }
    setState(() {});

    if (_duration.inSeconds == 0) drawChart();

    _timer = Timer.periodic(Duration(seconds: _interval), (_) {
      if (ApiBluetooth.statusSensor == false) {
        _stopTimer(reset: false);
        return;
      }

      if ((_duration.inSeconds / currentScaleX) >= maxX) {
        if (currentScaleX == scaleXOneHour) {
          _changeScaleX();
        } else {
          _timer?.cancel();
          setState(() {});
          return;
        }
      }

      _duration = Duration(seconds: _duration.inSeconds + _interval);
      drawChart();
    });
  }

  void _stopTimer({required bool reset}) {
    if (reset) {
      _duration = const Duration();
      coordinates = [const FlSpot(0, 0)];
      Settings.setCoordinatesChart(coordinates);
    }
    _timer?.cancel();
    setState(() {});
  }

  void _changeScaleX() {
    if (currentScaleX == scaleXOneHour) {
      currentScaleX = scaleXManyHours;
      Settings.setScaleAxisX(scaleXManyHours);
      coordinates = coordinates.map((e) => FlSpot(double.parse((e.x / maxHoursForStat).toStringAsFixed(5)), e.y)).toList();
    } else {
      if (coordinates.last.x * maxHoursForStat > maxX) {
        Helper.alert(context: context, content: Lang.text('Текущая статистика вышла за диапазон одного часа. Уменьшить масштаб нельзя.'));
        return;
      }
      currentScaleX = scaleXOneHour;
      Settings.setScaleAxisX(scaleXOneHour);
      coordinates = coordinates.map((e) {
        var newX = e.x * maxHoursForStat;
        return newX > maxX ? FlSpot(maxX, e.y) : FlSpot(newX, e.y);
      }).toList();
    }
    Settings.setCoordinatesChart(coordinates);
    setState(() {});
  }

  String axisY2temp({required num axisY}) {
    return (axisY / maxY * 125).toStringAsFixed(1);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _temperatureSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(Helper.celsius, style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(
            onPressed: _changeScaleX, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                currentScaleX == scaleXOneHour ? const Icon(Icons.arrow_forward, color: Colors.black, size: 24) 
                  : const Icon(Icons.arrow_back, color: Colors.black, size: 24) ,
                Text(currentScaleX == scaleXOneHour ? maxHoursForStat.toString() + Lang.text('ч.') : '1${Lang.text('ч.')}', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)
                ),
              ],
            )
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(Lang.text('График температуры'), style: const TextStyle(fontSize: 15)),
            ),
            Flexible(
              flex: 16,
              child: LineChart(
                LineChartData(
                  //? переопределяем в lineTouchData() подсказку при касании с координаты y на температуру
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map(
                          (LineBarSpot touchedSpot) {
                            return LineTooltipItem(
                              (touchedSpot.y / maxY * 125).toStringAsFixed(1) + Helper.celsius,
                              const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                            );
                          },
                        ).toList();
                      },
                    )
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: AppStyle.dottedColor,
                        strokeWidth: 0.5,
                        dashArray: [3, 3]
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: AppStyle.dottedColor,
                        strokeWidth: 0.5,
                        dashArray: [3, 3]
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: currentScaleX == scaleXOneHour ? bottomTitleWidgetsScaleHour : bottomTitleWidgetsScaleHours,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: leftTitleWidgets,
                        reservedSize: 25,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: AppStyle.dottedColor), 
                      bottom: BorderSide(color: AppStyle.dottedColor),
                      top: BorderSide(width: 0.3, color: AppStyle.dottedColor), 
                      right: BorderSide(width: 0.3, color: AppStyle.dottedColor), 
                    )
                  ),
                  minX: 0,
                  maxX: maxX,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: coordinates,
                      isCurved: true,
                      color: AppStyle.pinkColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: gradientColors
                              .map((color) => color)
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
            Flexible(
              flex: 5,
              child: _maxHoursForStat()
            ),
            Flexible(
              flex: 3,
              child: buildButtons()
            )
          ],
        ),
      ],
    );
  }

  Widget _maxHoursForStat() {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Text(Lang.text('Максимальный масштаб статистики (%s ч.)', [maxHoursForChart.round()]), 
            style: TextStyle(fontSize: Adaptive.text(12, context))
          ) 
        ),
        Flexible(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 5.0, 
                  overlayShape: SliderComponentShape.noOverlay,
                  showValueIndicator: ShowValueIndicator.always,
                  thumbColor: AppStyle.mainColor,
                  activeTrackColor: AppStyle.mainColor,
                ),
                child: Slider(
                  inactiveColor: Colors.grey.shade400,
                  value: maxHoursForChart,
                  min: 2,
                  max: 9,
                  divisions: 7,
                  label: maxHoursForChart.toDouble().round().toString(),
                  onChanged: (double value) {
                    maxHoursForChart = value;
                    setState(() {});
                  },
                  onChangeEnd: (double value) {
                    _dataProvider.setMaxHoursForStat(value.round());
                    Settings.maxHoursForChart = value.round();
                    _setAxisX(init: false);
                    setState(() {});
                  },
                ),
              ),
              Padding(
                padding:  const EdgeInsets.symmetric(horizontal: 9.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('2', style: TextStyle(fontSize: Adaptive.text(12, context), color: maxHoursForChart == 2 ? Colors.black : Colors.grey)),
                    Text('3', style: TextStyle(fontSize: Adaptive.text(12, context), color: maxHoursForChart == 3 ? Colors.black : Colors.grey)),
                    Text('4', style: TextStyle(fontSize: Adaptive.text(12, context), color: maxHoursForChart == 4 ? Colors.black : Colors.grey)),
                    Text('5', style: TextStyle(fontSize: Adaptive.text(12, context), color: maxHoursForChart == 5 ? Colors.black : Colors.grey)),
                    Text('6', style: TextStyle(fontSize: Adaptive.text(12, context), color: maxHoursForChart == 6 ? Colors.black : Colors.grey)),
                    Text('7', style: TextStyle(fontSize: Adaptive.text(12, context), color: maxHoursForChart == 7 ? Colors.black : Colors.grey)),
                    Text('8', style: TextStyle(fontSize: Adaptive.text(12, context), color: maxHoursForChart == 8 ? Colors.black : Colors.grey)),
                    Text('9', style: TextStyle(fontSize: Adaptive.text(12, context), color: maxHoursForChart == 9 ? Colors.black : Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildButtons() {
    final isRunning = _timer != null && _timer!.isActive;

    if (!isRunning && _duration.inSeconds == 0) {
      return InkResponse(
        onTap: _startTimer,
        child: AppStyle.getButton(color: AppStyle.colorButtonGreen, text: Lang.text('Старт')),
      );
    }

    if (isRunning) {
      return InkResponse(
        onTap: () => _stopTimer(reset: false),
        child: AppStyle.getButton(color: AppStyle.colorButtonOrange, text: Lang.text('Пауза')),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkResponse(
          onTap: () => _startTimer(),
          child: AppStyle.getButton(color: AppStyle.colorButtonBlue, text: Lang.text('Продолж.')),
        ),
        const SizedBox(width: 15),
        InkResponse(
          onTap: () => _stopTimer(reset: true),
          child: AppStyle.getButton(color: AppStyle.colorButtonRed, text: Lang.text('Сбросить')),
        ),
      ],
    );
  }

  Widget bottomTitleWidgetsScaleHour(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12);
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('0', style: style); break;
      case 2:
        text = const Text('10', style: style); break;
      case 4:
        text = const Text('20', style: style); break;
      case 6:
        text = const Text('30', style: style); break;
      case 8:
        text = const Text('40', style: style); break;
      case 10:
        text = const Text('50', style: style); break;
      case 12:
        text = const Text('60', style: style); break;
      case 14:
        text = const Text('min', style: TextStyle(fontWeight: FontWeight.bold)); break;
      default:
        text = const Text('', style: style); break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

  Widget bottomTitleWidgetsScaleHours(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12);
    Widget text;
    double titleX = (maxHoursForStat / 6);
    switch (value.toInt()) {
      case 0:
        text = const Text('0', style: style); break;
      case 2:
        text = Text(titleX.toStringAsFixed(1), style: style); break;
      case 4:
        text = Text((titleX * 2).toStringAsFixed(1), style: style); break;
      case 6:
        text = Text((titleX * 3).toStringAsFixed(1), style: style); break;
      case 8:
        text = Text((titleX * 4).toStringAsFixed(1), style: style); break;
      case 10:
        text = Text((titleX * 5).toStringAsFixed(1), style: style); break;
      case 12:
        text = Text(maxHoursForStat.toString(), style: style); break;
      case 14:
        text = const Text('hours', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)); break;
      default:
        text = const Text('', style: style); break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

   Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12);
    switch (value.toInt()) {
      case 0:
        return const Text('0', style: style, textAlign: TextAlign.left);
      case 2:
        return const Text('25', style: style, textAlign: TextAlign.left);
      case 4:
        return const Text('50', style: style, textAlign: TextAlign.left);
      case 6:
        return const Text('75', style: style, textAlign: TextAlign.left);
      case 8:
        return const Text('100', style: style, textAlign: TextAlign.left);
      default:
        return Container();
    }
  }
}