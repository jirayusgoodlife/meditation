import 'package:flutter/material.dart';

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
                  Image.asset('assets/images/logo_app.png',width: 80,height: 80),
                  Text('เจริญสติ', style: Theme.of(context).textTheme.headline, textAlign: TextAlign.center),                  
                  Container(height: 18.0),
                  Text('© 2020 Jirayus Arbking', style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center),
                  Text('คณะเทคโนโลยีสารสนเทศ มหาวิทยาลัยเทคโนโลยีพระจอมเกล้าธนบุรี', style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center),
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
                  Text('Illustration vector created by stories - www.freepik.comr', style: Theme.of(context).textTheme.body1, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
  }

  
}