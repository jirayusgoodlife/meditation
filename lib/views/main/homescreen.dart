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
    Firestore.instance
        .collection('users')
        .where("uid", isEqualTo: user.uid)
        .snapshots()
        .listen((data) {
      if (data.documents.isEmpty) {
        Firestore.instance.collection('users').document().setData({
          'uid': user.uid,
          'numberTrainToday': '0',
          'numberTrainWeekly': '0',
          'numberTrainMonthly': '0',
          'numberTrainLastMonth': '0',
          'userTarget': '15',          
        });
      } else {
        data.documents.forEach((doc) {
          setState(() {
            numberTrainToday = int.parse(doc['numberTrainToday']);
            numberTrainWeekly = int.parse(doc['numberTrainWeekly']);
            numberTrainMonthly = int.parse(doc['numberTrainMonthly']);
            numberTrainLastMonth = int.parse(doc['numberTrainLastMonth']);
            userTarget = int.parse(doc['userTarget']);
            listViews[1] = DashboardView(
                animation: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animationController,
                    curve: Interval((1 / 4) * 1, 1.0,
                        curve: Curves.fastOutSlowIn))),
                animationController: animationController,
                numberTrainLastMonth: numberTrainLastMonth,
                numberTrainMonthly: numberTrainMonthly,
                numberTrainToday: numberTrainToday,
                numberTrainWeekly: numberTrainWeekly,
                userTarget: userTarget);
          });
        });
      }
    });
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
