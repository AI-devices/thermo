import 'package:flutter_svg/flutter_svg.dart';

abstract class AppAssets {
  static const String alarmAudio = 'assets/notify.wav';
  static const String alarmAudioLong = 'assets/notify_long.wav';

  static final arrowRight = SvgPicture.asset('assets/arrow_right.svg', semanticsLabel: 'arrow_right');
  static final arrowDown1 = SvgPicture.asset('assets/arrow_down_1.svg', semanticsLabel: 'arrow_down_1');
  static final arrowDown2 = SvgPicture.asset('assets/arrow_down_2.svg', semanticsLabel: 'arrow_down_2');
  static final arrowDown3 = SvgPicture.asset('assets/arrow_down_3.svg', semanticsLabel: 'arrow_down_3');
  static final arrowDown4 = SvgPicture.asset('assets/arrow_down_4.svg', semanticsLabel: 'arrow_down_4');
  static final arrowUp1 = SvgPicture.asset('assets/arrow_up_1.svg', semanticsLabel: 'arrow_up_1');
  static final arrowUp2 = SvgPicture.asset('assets/arrow_up_2.svg', semanticsLabel: 'arrow_up_2');
  static final arrowUp3 = SvgPicture.asset('assets/arrow_up_3.svg', semanticsLabel: 'arrow_up_3');
  static final arrowUp4 = SvgPicture.asset('assets/arrow_up_4.svg', semanticsLabel: 'arrow_up_4');
}