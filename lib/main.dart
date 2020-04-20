import 'package:flutter/material.dart';
import 'package:meditation/theme/primarytheme.dart';

void main() {
   runApp(new MaterialApp(
      title: 'เจริญสติ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: PrimaryTheme.textTheme,
      ),
    ));
}
