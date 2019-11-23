import 'package:flutter/material.dart';
import 'package:meditation/widgets/home_theme.dart';
import 'package:meditation/screens/home_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'เจริญสติ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: HomeAppTheme.textTheme,
      ),
      home: MyHomePage(),
    );
  }
}