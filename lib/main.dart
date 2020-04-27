import 'package:flutter/material.dart';
import 'package:meditation/theme/primary.dart';
import 'package:meditation/views/splash/loadingpage.dart';

void main() {
   runApp(new MaterialApp(
      title: 'เจริญสติ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: PrimaryTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      home: LoadingPage(),
    ));
}
