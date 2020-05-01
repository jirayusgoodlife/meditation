import 'package:flutter/material.dart';
import 'package:meditation/theme/primary.dart';

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
          style: Theme.of(context).textTheme.caption,
          child: SafeArea(
            bottom: false,
            child: Scrollbar(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                children: <Widget>[
                  Text('เจริญสติ', style: Theme.of(context).textTheme.headline, textAlign: TextAlign.center),
                  IconTheme(data: Theme.of(context).iconTheme, child: Image.asset('assets/images/logo_app.png')),
                  Text('1.0', style: Theme.of(context).textTheme.body1, textAlign: TextAlign.center),
                  Container(height: 18.0),
                  Text('© 2020 Jirayus Arbking, SIT, KMUTT', style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center),
                  Container(height: 18.0),
                  Text('Powered by Flutter', style: Theme.of(context).textTheme.body1, textAlign: TextAlign.center),
                  Container(height: 24.0),
                  
                ],
              ),
            ),
          ),
        );
  }

  
}


class _LinkTextSpan extends TextSpan {

  // Beware!
  //
  // This class is only safe because the TapGestureRecognizer is not
  // given a deadline and therefore never allocates any resources.
  //
  // In any other situation -- setting a deadline, using any of the less trivial
  // recognizers, etc -- you would have to manage the gesture recognizer's
  // lifetime and call dispose() when the TextSpan was no longer being rendered.
  //
  // Since TextSpan itself is @immutable, this means that you would have to
  // manage the recognizer from outside the TextSpan, e.g. in the State of a
  // stateful widget that then hands the recognizer to the TextSpan.

  _LinkTextSpan({ TextStyle style, String url, String text }) : super(
    style: style,
    text: text ?? url,
    recognizer: TapGestureRecognizer()..onTap = () {
      launch(url, forceSafariVC: false);
    }
  );
}

void showGalleryAboutDialog(BuildContext context) {
  final ThemeData themeData = Theme.of(context);
  final TextStyle aboutTextStyle = themeData.textTheme.body2;
  final TextStyle linkStyle = themeData.textTheme.body2.copyWith(color: themeData.accentColor);

  showAboutDialog(
    context: context,
    applicationVersion: 'January 2019',
    applicationIcon: const FlutterLogo(),
    applicationLegalese: '© 2019 The Chromium Authors',
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                style: aboutTextStyle,
                text: 'Flutter is an open-source project to help developers '
                      'build high-performance, high-fidelity, mobile apps for '
                      '${defaultTargetPlatform == TargetPlatform.iOS ? 'multiple platforms' : 'iOS and Android'} '
                      'from a single codebase. This design lab is a playground '
                      "and showcase of Flutter's many widgets, behaviors, "
                      'animations, layouts, and more. Learn more about Flutter at ',
              ),
              _LinkTextSpan(
                style: linkStyle,
                url: 'https://flutter.dev',
              ),
              TextSpan(
                style: aboutTextStyle,
                text: '.\n\nTo see the source code for this app, please visit the ',
              ),
              _LinkTextSpan(
                style: linkStyle,
                url: 'https://goo.gl/iv1p4G',
                text: 'flutter github repo',
              ),
              TextSpan(
                style: aboutTextStyle,
                text: '.',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
