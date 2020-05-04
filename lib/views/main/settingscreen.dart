import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditation/theme/primary.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:meditation/models/setting.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  SettingData userTarget = SettingData("userTraget", "15");
  SettingData autoExit = SettingData("autoExit", false);
  SettingData vibrationStatus = SettingData("vibrationStatus", false);

  TextEditingController _cUserTarget;

  String docId = "";

  @override
  void initState() {
    _cUserTarget = TextEditingController(text: userTarget.value.toString());
    getUserData();
    getPrefrerence();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PrimaryTheme.nearlyWhite,
      child: SafeArea(
          top: true,
          bottom: false,
          child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(children: <Widget>[
                getAppBarUI(context),
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                  getAboutUserSetting(context),
                  Divider(height: 1),
                  getAboutApplicationSetting(context)
                ]))),
                Divider(height: 1),
                getSaveButton(context)
              ]))),
    );
  }

  Widget getAboutUserSetting(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            FlutterI18n.translate(context, 'main.setting.aboutUser'),
            textAlign: TextAlign.left,
            style: PrimaryTheme.headerSetting,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: Column(
            children: <Widget>[
              getText('จำนวนเป้าหมายในการฝึก', userTarget, _cUserTarget,
                  "[0-9]", () {})
            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget getAboutApplicationSetting(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            FlutterI18n.translate(context, 'main.setting.aboutApp'),
            textAlign: TextAlign.left,
            style: PrimaryTheme.headerSetting,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: Column(
            children: <Widget>[
              getSwitch(FlutterI18n.translate(context, 'main.setting.autoExit'),
                  autoExit, () {
                autoExit.value = !autoExit.value;
              }),
              getSwitch(
                  FlutterI18n.translate(
                      context, 'main.setting.vibrationStatus'),
                  vibrationStatus, () {
                vibrationStatus.value = !vibrationStatus.value;
              }),
            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget getSwitch(String title, SettingData data, var callback) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        onTap: () {
          setState(() {
            if (callback != null) {
              callback();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              CupertinoSwitch(
                activeColor: data.value
                    ? PrimaryTheme.primaryColor
                    : Colors.grey.withOpacity(0.6),
                onChanged: (value) {
                  setState(() {
                    data.value = !data.value;
                  });
                },
                value: data.value,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getText(String title, SettingData data,
      TextEditingController controller, String regexp, var callback) {
    if (regexp == null) {
      regexp = "[A-Z]";
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        onTap: () {
          setState(() {
            if (callback != null) {
              callback();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Container(
                width: 80,
                decoration: BoxDecoration(
                  color: PrimaryTheme.backgroundColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 8.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4, right: 4, top: 4, bottom: 4),
                  child: TextField(
                    // WhitelistingTextInputFormatter RegExp
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp(regexp))
                    ],
                    controller: controller,
                    onChanged: (value) {
                      userTarget.value = value;
                    },
                    keyboardType: TextInputType.number,
                    style: PrimaryTheme.body1,
                    textAlign: TextAlign.center,
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void savePrefrerence(SettingData data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(data.name, data.value);
  }

  void getPrefrerence() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var key = "autoExit";
    if (prefs.getBool(key) != null) {
      setState(() {
        autoExit = SettingData(key, prefs.getBool(key));
      });
    }
    key = "vibrationStatus";
    if (prefs.getBool(key) != null) {
      setState(() {
        vibrationStatus = SettingData(key, prefs.getBool(key));
      });
    }
  }

  void getUserData() async {
    final FirebaseUser user = await _auth.currentUser();
    Firestore.instance
        .collection('users')
        .where("uid", isEqualTo: user.uid)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) {
              if (doc['userTarget'] != null) {
                setState(() {
                  docId = doc.documentID;
                  userTarget.value = doc['userTarget'];
                  _cUserTarget =
                      TextEditingController(text: userTarget.value.toString());
                });
              }
            }));
  }

  void updateUserTarget() async{    
    setState(() {
       userTarget.value = int.parse(userTarget.value).toString();
      _cUserTarget =
          TextEditingController(text: userTarget.value.toString());
    });
    if(docId != "")
      Firestore.instance.collection('users').document(docId).updateData({'userTarget': int.parse(userTarget.value).toString() });        
  }

  Widget getSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: PrimaryTheme.primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              blurRadius: 8,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            highlightColor: Colors.transparent,
            onTap: () {
              ProgressDialog pr = new ProgressDialog(context);
              pr.style(message: FlutterI18n.translate(context, 'saving'));
              pr.show();              
              savePrefrerence(autoExit);
              savePrefrerence(vibrationStatus);
              updateUserTarget();              
              Future.delayed(Duration(seconds: 2), (){
                  pr.hide();
              });              
            },
            child: Center(
              child: Text(
                FlutterI18n.translate(context, 'main.setting.save'),
                style: PrimaryTheme.body1White,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getAppBarUI(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PrimaryTheme.backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            width: 0,
            height: AppBar().preferredSize.height,
          ),
          Expanded(
              child: Center(
                  child: Text(FlutterI18n.translate(context, 'menu.setting'),
                      style: PrimaryTheme.headline))),
        ],
      ),
    );
  }

 
}
