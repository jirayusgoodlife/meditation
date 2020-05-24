import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:meditation/theme/primary.dart';
import 'package:meditation/views/album/albumscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation/widgets/listSimpleCategoryView.dart';
import 'package:meditation/widgets/dashboardView.dart';
import 'package:meditation/widgets/titleView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Widget> listViews = new List<Widget>();
  var scrollController = ScrollController();
  double topBarOpacity = 0.0;

  int numberTrainToday;
  int numberTrainWeekly;
  int numberTrainMonthly;
  int numberTrainLastMonth;
  int userTarget;

  AnimationController animationController;

  @override
  void initState() {
    numberTrainToday = 0;
    numberTrainWeekly = 0;
    numberTrainMonthly = 0;
    numberTrainLastMonth = 0;
    userTarget = 15;
    animationController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
    Future.delayed(Duration.zero, () {
      addAllListData(context);
      getUserData();
    });

    super.initState();
  }

  getUserData() async {
    final FirebaseUser user = await _auth.currentUser();
    QuerySnapshot dataUsers = await Firestore.instance
        .collection('users')
        .where("uid", isEqualTo: user.uid)
        .getDocuments();

    // ทีข้อมูลผู้ใช้
    if (dataUsers.documents.length > 0) {
      DocumentSnapshot doc = dataUsers.documents[0];

      // set default by user data
      setState(() {
        numberTrainToday = int.parse(doc['numberTrainToday']);
        numberTrainWeekly = int.parse(doc['numberTrainWeekly']);
        numberTrainMonthly = int.parse(doc['numberTrainMonthly']);
        numberTrainLastMonth = int.parse(doc['numberTrainLastMonth']);
        userTarget = int.parse(doc['userTarget']);
      });

      // get log
      DateTime today = DateTime.now();
      DateTime _firstDayOfTheweek =
          today.subtract(new Duration(days: today.weekday));
      QuerySnapshot logTimeByUser = await Firestore.instance
          .collection('logTime')
          .where("uid", isEqualTo: user.uid)
          .where("day", isEqualTo: today.day)
          .where("month", isEqualTo: today.month)
          .where("year", isEqualTo: today.year)
          .getDocuments();

      // ยังไม่มี log
      if (!(logTimeByUser.documents.length > 0)) {
        // set today = 0
        setState(() {
          numberTrainToday = 0;
        });
        // วันแรกของ week ?
        if (_firstDayOfTheweek.day <= today.day) {
          // set week = 0
          setState(() {
            numberTrainWeekly = 0;
          });
        }
        // TODO : fix bug on set last month
        if (1 == today.day ) {
          // move numberTrainMonthly => numberTrainLastMonth
          // set numberTrainMonthly = 0
          print("=-=-=-=-=-=-=-=-=-=-=-=");
          print("1 == today ?");
          print("=-=-=-=-=-=-=-=-=-=-=-=");
          setState(() {
            numberTrainLastMonth = numberTrainMonthly;
            numberTrainMonthly = 0;
          });
        }
        // update user
        Firestore.instance
            .collection('users')
            .document(dataUsers.documents[0].documentID)
            .updateData({
          'numberTrainToday': numberTrainToday.toString(),
          'numberTrainWeekly': numberTrainWeekly.toString(),
          'numberTrainMonthly': numberTrainMonthly.toString(),
          'numberTrainLastMonth': numberTrainLastMonth.toString()
        });
      }

      // update list
      setState(() {
        listViews[1] = DashboardView(
            animation: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                parent: animationController,
                curve:
                    Interval((1 / 4) * 1, 1.0, curve: Curves.fastOutSlowIn))),
            animationController: animationController,
            numberTrainLastMonth: numberTrainLastMonth,
            numberTrainMonthly: numberTrainMonthly,
            numberTrainToday: numberTrainToday,
            numberTrainWeekly: numberTrainWeekly,
            userTarget: userTarget);
      });
    } else {
      Firestore.instance.collection('users').document().setData({
        'uid': user.uid,
        'numberTrainToday': '0',
        'numberTrainWeekly': '0',
        'numberTrainMonthly': '0',
        'numberTrainLastMonth': '0',
        'userTarget': '15',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: PrimaryTheme.nearlyWhite,
        child: SafeArea(
            top: false,
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(children: <Widget>[getMainListViewUI()]))));
  }

  void addAllListData(BuildContext context) {
    var count = 4;
    listViews.add(
      TitleView(
        titleTxt: FlutterI18n.translate(context, 'main.homepage.title_01'),
        subTxt: '',
        icon: FontAwesomeIcons.syncAlt,
        animation: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: animationController,
            curve:
                Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: animationController,
        isShowSubIcon: true,
        callback: () {
          getUserData();
        },
      ),
    );

    listViews.add(
      DashboardView(
          animation: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: animationController,
              curve:
                  Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
          animationController: animationController,
          numberTrainLastMonth: numberTrainLastMonth,
          numberTrainMonthly: numberTrainMonthly,
          numberTrainToday: numberTrainToday,
          numberTrainWeekly: numberTrainWeekly,
          userTarget: userTarget),
    );
    listViews.add(
      TitleView(
        titleTxt: FlutterI18n.translate(context, 'main.homepage.title_02'),
        subTxt: FlutterI18n.translate(context, 'main.homepage.more'),
        animation: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: animationController,
            curve:
                Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: animationController,
        callback: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AlbumScreenView()),
          );
        },
      ),
    );

    listViews.add(
      ListSimpleCategoryView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: animationController,
                curve: Interval((1 / count) * 3, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: animationController,
      ),
    );
  }

  Future<bool> getData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  Widget getMainListViewUI() {
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              animationController.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }
}
