import 'package:flutter/material.dart';
import 'package:meditation/theme/primary.dart';
import 'package:meditation/models/menu_navigation.dart';

// rount
import 'package:meditation/views/main/homescreen.dart';

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget screenView;
  DrawerIndex drawerIndex;
  AnimationController sliderAnimationController;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = HomeScreen(); //first view
    super.initState();
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
          screenView = HomeScreen();
        });

      }  else if (drawerIndex == DrawerIndex.FEEDBACK) {
        setState(() {
          screenView = HomeScreen();
        });

      } else if (drawerIndex == DrawerIndex.SETTING) {
        setState(() {
          screenView = HomeScreen();
        });

      } else if (drawerIndex == DrawerIndex.ABOUT) {
        setState(() {
          screenView = HomeScreen();
        });

      } else {
        //error ?
      }
    }
  }
}

