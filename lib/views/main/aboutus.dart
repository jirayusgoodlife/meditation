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
                  Container(height: 18.0),
                  Text('© 2020 Jirayus Arbking, SIT, KMUTT', style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Icon(
                        Icons.insert_emoticon,
                        color: const Color(0xFF000000),
                        size: 48.0),
            
                      new Icon(
                        Icons.insert_emoticon,
                        color: const Color(0xFF000000),
                        size: 48.0)
                    ]
                  ),
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