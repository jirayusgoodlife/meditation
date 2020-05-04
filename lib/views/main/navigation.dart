import 'package:flutter/material.dart';
import 'package:meditation/theme/primary.dart';
import 'package:meditation/models/menu_navigation.dart';
import 'package:meditation/views/login/loginscreen.dart';
import 'package:meditation/views/main/aboutus.dart';
import 'package:meditation/views/main/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditation/views/main/settingscreen.dart';
import 'package:meditation/views/main/sharescreen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget screenView;
  DrawerIndex drawerIndex;
  AnimationController sliderAnimationController;

  checkAuth() async {
    
    final FirebaseUser user = await _auth.currentUser();
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      } 
  }

  @override
  void initState() {    
    super.initState();
    //check auth
    Future.delayed(Duration.zero,() {
      checkAuth();
    });
    drawerIndex = DrawerIndex.HOME;
    screenView = HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PrimaryTheme.nearlyWhite,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: PrimaryTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            animationController: (AnimationController animationController) {
              sliderAnimationController = animationController;
            },
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
            },
            screenView: screenView,
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      if (drawerIndex == DrawerIndex.HOME) {
        setState(() {
          screenView = HomeScreen();
        });
      } else if (drawerIndex == DrawerIndex.SHARE) {
        setState(() {
          screenView = ShareScreen();
        });

      } else if (drawerIndex == DrawerIndex.SETTING) {
        setState(() {
          screenView = SettingScreen();
        });

      } else if (drawerIndex == DrawerIndex.ABOUT) {
        setState(() {
          screenView = AboutUsScreen();
        });

      } else {
        //error ?
      }
    }
  }
}

