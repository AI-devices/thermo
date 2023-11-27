import 'dart:async';
import 'dart:developer';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:thermo/components/api_bluetooth.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/components/settings.dart';
import 'package:thermo/components/styles.dart';

class StatisticsWidget extends StatefulWidget {
  const StatisticsWidget({super.key});

  @override
  State<StatisticsWidget> createState() => _StatisticsWidgetState();
}

class _StatisticsWidgetState extends State<StatisticsWidget> {
  final List<Color> gradientColors = [
    Colors.blue,
    Colors.orange,
    Colors.red,
  ];

  StreamSubscription<double>? _temperatureSubscription;
  double? _currentTemperature;
  List<FlSpot> coordinates = [const FlSpot(0, 0)];

  Timer? _timer;
  Duration _duration = const Duration();
  final int _interval = Settings.envDebug ? 5 : 60; //в тестах обновляем через 5 сек, на проде - через минуту

  double maxY = 10;
  double maxX = 15;
  double x = 0;
  double y = 0;
  
  late int maxHoursForStat;
  final double scaleXOneHour = 300; //1 деление - 5 мин (300 сек)
  late double scaleXManyHours; //зависит от настроек, вычисляется в _init()
  late double currentScaleX; //одно деление по оси X
  static const double _currentScaleY = 12.5; //одно деление по оси Y - 12.5 градусов

  @override
  void initState() {
    super.initState();
    currentScaleX = scaleXOneHour;
    _temperatureSubscription = ApiBluetooth.temperatureStream.listen((double temperature) => _currentTemperature = temperature);
    _setAxisX();

    Settings.maxHoursForStatChanged ??= () {
      _setAxisX();
      setState(() {});
    };
  }

  void _setAxisX() {
    maxHoursForStat = Settings.maxHoursForStat;
    scaleXManyHours = (maxHoursForStat * 60 * 60) / 12; //переводим часы в секунды и делим на 12,т.к.на этой ячейке по оси X указано последнее значение
  }

  void drawStatistic() {
    x = double.parse((_duration.inSeconds / currentScaleX).toStringAsFixed(5));
    y = double.parse((_currentTemperature! / _currentScaleY).toStringAsFixed(5));

    FlSpot flSpot = FlSpot(x, y > maxY ? maxY : y);

    log(flSpot.props.toString());
    coordinates.add(flSpot);
    setState(() {});
  }

  void _startTimer() {
    if (ApiBluetooth.statusSensor == false || _currentTemperature == null) {
      Helper.alert(context: context, content: 'Нет подключения к датчику');
      return;
    }
    setState(() {});

    if (_duration.inSeconds == 0) drawStatistic();
    Settings.statisticsOn = true;

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
      drawStatistic();
    });
  }

  void _stopTimer({required bool reset}) {
    if (reset) {
      _duration = const Duration();
      coordinates = [const FlSpot(0, 0)];
      Settings.statisticsOn = false;
    }
    _timer?.cancel();
    setState(() {});
  }

  void _changeScaleX() {
    if (currentScaleX == scaleXOneHour) {
      currentScaleX = scaleXManyHours;
      coordinates = coordinates.map((e) => FlSpot(double.parse((e.x / maxHoursForStat).toStringAsFixed(5)), e.y)).toList();
    } else {
      if (coordinates.last.x * maxHoursForStat > maxX) {
        Helper.alert(context: context, content: 'Текущая статистика вышла за диапазон одного часа. Уменьшить масштаб нельзя.');
        return;
      }
      currentScaleX = scaleXOneHour;
      coordinates = coordinates.map((e) {
        var newX = e.x * maxHoursForStat;
        return newX > maxX ? FlSpot(maxX, e.y) : FlSpot(newX, e.y);
      }).toList();
  }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _temperatureSubscription?.cancel();
    Settings.statisticsOn = false;
    Settings.maxHoursForStatChanged = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Text(Helper.celsius, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(
            onPressed: _changeScaleX, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                currentScaleX == scaleXOneHour ? const Icon(Icons.arrow_forward, color: AppStyle.barColor, size: 20) 
                  : const Icon(Icons.arrow_back, color: AppStyle.barColor, size: 20) ,
                Text(currentScaleX == scaleXOneHour ? '$maxHoursForStatч' : '1ч', 
                  style: const TextStyle(color: AppStyle.barColor)
                ),
              ],
            )
          ),
        ),
        Column(
          children: [
            Flexible(
              flex: 5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: AppStyle.barColor,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: AppStyle.barColor,
                        strokeWidth: 1,
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
                    border: Border.all(color: const Color(0xff37434d)),
                  ),
                  minX: 0,
                  maxX: maxX,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: coordinates,
                      isCurved: true,
                      color: AppStyle.barColor,
                      /*gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topLeft,
                        colors: gradientColors,
                      ),*/
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        /*gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topLeft,
                          colors: gradientColors
                              .map((color) => color.withOpacity(0.3))
                              .toList(),
                        ),*/
                      ),
                    ),
                  ],
                )
              ),
            ),
            Flexible(
              flex: 1,
              child: buildButtons()
            )
          ],
        ),
      ],
    );
  }

  Widget buildButtons() {
    final isRunning = _timer != null && _timer!.isActive;

    return isRunning || _duration.inSeconds != 0
      ? SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Row(
            //mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: MaterialButton(
                  height: 32.0, 
                  minWidth: 70.0, 
                  color: isRunning ? Colors.black : Colors.green, 
                  textColor: Colors.white,
                  onPressed: () => isRunning ? _stopTimer(reset: false) : _startTimer(), 
                  child: isRunning ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MaterialButton( 
                  height: 32.0, 
                  minWidth: 70.0, 
                  color: Colors.red, 
                  textColor: Colors.white, 
                  onPressed: () => _stopTimer(reset: true),
                  child: const Icon(Icons.stop), 
                ),
              ),
            ],
          ),
      )

      : MaterialButton( 
          height: 32.0, 
          minWidth: 70.0, 
          color: Colors.green, 
          textColor: Colors.white, 
          onPressed: _startTimer, 
          child: const Icon(Icons.play_arrow), 
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
        text = const Text('min', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)); break;
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