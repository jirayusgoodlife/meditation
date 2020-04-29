import 'package:flutter/material.dart';
import 'package:meditation/theme/primary.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

//page
import 'package:meditation/views/main/navigation.dart';
import 'package:meditation/views/intro/introscreen.dart';
import 'package:meditation/views/login/loginscreen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

 StatefulWidget redirect = IntroScreen();
       
  selectHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final FirebaseUser user = await _auth.currentUser();
    if(prefs.getBool("see_intro")){
      if (user == null) {
        setState(() {
          redirect = SignInPage();
        });   
      } else {
        setState(() {
          redirect = NavigationHomeScreen();
        });    
      } 
    }     
  }
 @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      selectHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 2,
        navigateAfterSeconds: redirect ,
        title: Text(
          'เจริญสติ',
          style: PrimaryTheme.headline,
        ),
        image: Image.asset('assets/images/logo_app.png'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: TextStyle(color: Colors.pink[200]),
        photoSize: 100.0,
        loaderColor: Colors.pinkAccent);
  }
}