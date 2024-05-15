import 'package:flutter_svg/flutter_svg.dart';

abstract class AppAssets {
  static const String alarmAudio = 'assets/notify.wav';
  static const String alarmAudioLong = 'assets/notify_long.wav';

  static final iconDelta = SvgPicture.asset(
    'assets/delta.svg',
    semanticsLabel: 'delta',
    //alignment: Alignment.bottomCenter,
  );
}