import 'package:flutter/material.dart';
import 'package:thermo/components/styles.dart';
import 'package:thermo/main.dart';
import 'package:thermo/widgets/init.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Mir.Dev',
      theme: ThemeData(
        scaffoldBackgroundColor: AppStyle.backgroundColor,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppStyle.mainColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: AppStyle.backgroundColor,
          //showSelectedLabels: false,
          //showUnselectedLabels: false,
        ),
      ),
      home: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)), //? игнорируем размер текста, заданный на уровне ОС
        child: const InitWidget(title: 'Main page')
      ),
    );
  }
}