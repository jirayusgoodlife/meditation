import 'dart:async';
import 'dart:io';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:audio_service/audio_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meditation/models/hexcode.dart';
import 'package:meditation/models/list_data.dart';
import 'package:flutter/material.dart';
import 'package:meditation/views/player/review.dart';
import 'package:sys_volume/flutter_volume.dart';
import 'package:meditation/theme/primary.dart';
import 'package:meditation/widgets/sliderButton.dart';
import 'package:vibration/vibration.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:meditation/models/audio_player_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PlayerScreen extends StatefulWidget {
  PlayerScreen({Key key, this.musicListData}) : super(key: key);
  final MusicListData musicListData;
  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  double volume = 0;

  // String _countdownAnimation = "countdown"; // idle , countdown
  String _breathingAnimation = "breathing"; // idle , breathing

  bool isStart = false;
  bool vibrationStatus = false;
  bool autoExit = false;

  Timer _timer;
  int sec = 0;
  int min = 0;
  int hour = 0;
  String userDocId = "";
  String logTimeDocId = "";
  int numberTrainToday = 0;
  int numberTrainWeekly = 0;
  int numberTrainMonthly = 0;

  @override
  void initState() {
    super.initState();

    FlutterVolume.get().then((v) {
      setState(() {
        volume = v;
      });
    });

    AudioService.start(
      backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
      androidNotificationChannelName: 'เจริญสติ',
      notificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      enableQueue: true,
    );

    getUserDocId();
    getPrefrerence();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async => false,
        child: Container(
            color: PrimaryTheme.nearlyWhite,
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: VolumeWatcher(
                  watcher: (vol) {
                    setState(() {
                      volume = vol.vol;
                    });
                  },
                  child: Column(children: <Widget>[
                    Expanded(
                        child: Stack(fit: StackFit.expand, children: <Widget>[
                      Image.network(
                        'https://www.debuda.net/wp-content/uploads/2017/11/como-decorar-una-habitacion-para-meditar.jpg',
                        fit: BoxFit.cover,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              HexColor(widget.musicListData.startColor)
                                  .withOpacity(0.92),
                              HexColor(widget.musicListData.endColor)
                                  .withOpacity(0.92),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      getHeader(size),
                      getTimer(size),
                      getAnimation(size)
                    ])),
                    Container(
                        width: size.width,
                        height: size.height * .28,
                        child: Stack(fit: StackFit.expand, children: <Widget>[
                          Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    HexColor(widget.musicListData.endColor)
                                        .withOpacity(0.92),
                                    HexColor(widget.musicListData.endColor)
                                        .withOpacity(0.92)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Center(child: stopPlayer())
                                  ]))
                        ]))
                  ]),
                ))));
  }

  // UI
  Widget getAnimation(Size size) {
    return Positioned(
      top: 0,
      width: size.width,
      height: size.height - size.height * .3,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          isStart
              ? FlareActor(
                  "assets/animation/haayai.flr",
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: _breathingAnimation,
                )
              : Container(),
          GestureDetector(
              onTap: () async {
                await play();
                setState(() {
                  isStart = true;
                });
                startTimer();
              },
              child: Container(
                width: size.width,
                //height: size.height - size.height * .28,
                alignment: Alignment.center,
                child: StreamBuilder<PlaybackState>(
                  stream: AudioService.playbackStateStream,
                  builder: (context, snapshot) {
                    final state =
                        snapshot.data?.basicState ?? BasicPlaybackState.stopped;
                    if (state == BasicPlaybackState.playing)
                      return SizedBox(
                        width: 150,
                        height: 150,
                      );
                    return Icon(Icons.play_arrow,
                        size: 50, color: Colors.white);
                  },
                ),
              ))
        ],
      ),
    );
  }

  Widget getTimer(Size size) {
    final String minutesStr = (min).toString().padLeft(2, '0');
    final String secondsStr = (sec).toString().padLeft(2, '0');
    return Positioned(
        bottom: 10,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Icon(
                      Icons.watch_later,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "$minutesStr:$secondsStr",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget getHeader(Size size) {
    return Positioned(
        top: 40,
        width: size.width,
        child: Container(
            alignment: Alignment.topRight,
            width: size.width,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: getIconSpeaker())));
  }

  Widget stopPlayer() {
    return SliderButton(
      dismissible: false,
      height: 50,
      buttonSize: 40,
      radius: 5,
      buttonRadius: 100,
      action: () async {
        setState(() {
          isStart = false;
        });
        ProgressDialog pr = new ProgressDialog(context);
        pr.style(message: FlutterI18n.translate(context, 'saving'));
        stop();
        pr.show();
        await saveTime();
        Future.delayed(Duration(seconds: 2), () {
          pr.hide();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ReviewScreen(mid: widget.musicListData.mid)),
          );
        });
        Vibration.vibrate(duration: 100);
        //Navigator.of(context).pop();
        // Todo : save to firebase
      },
      label: Text(
        FlutterI18n.translate(context, 'player.main.slideStop'),
        style: PrimaryTheme.body1,
      ),
      icon: Icon(
        Icons.stop,
        color: Colors.red,
        size: 25.0,
        semanticLabel: 'Button Stop Meditation Program',
      ),
    );
  }

  Widget getIconSpeaker() {
    if (volume < 0.1) {
      return FaIcon(
        FontAwesomeIcons.volumeOff,
        size: 20,
        color: Colors.white,
      );
    }

    if (volume < 0.6) {
      return FaIcon(
        FontAwesomeIcons.volumeDown,
        size: 20,
        color: Colors.white,
      );
    }

    if (volume > 0.8) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.volumeUp,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            FaIcon(
              FontAwesomeIcons.exclamation,
              size: 20,
              color: Colors.red,
            ),
          ]);
    }

    return FaIcon(
      FontAwesomeIcons.volumeUp,
      size: 20,
      color: Colors.white,
    );
  }

  // action
  play() async {
    if (AudioService.running) {
      AudioService.addQueueItem(MediaItem(
        id: widget.musicListData.music,
        album: widget.musicListData.album,
        title: widget.musicListData.title,
        artist: widget.musicListData.artist,
        artUri: widget.musicListData.imagePath,
      ));
      await AudioService.playFromMediaId(widget.musicListData.music);
    } else {
      await AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
        androidNotificationChannelName: 'เจริญสติ',
        notificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
        enableQueue: true,
      );
      AudioService.addQueueItem(MediaItem(
        id: widget.musicListData.music,
        album: widget.musicListData.album,
        title: widget.musicListData.title,
        artist: widget.musicListData.artist,
        artUri: widget.musicListData.imagePath,
      ));
      await AudioService.playFromMediaId(widget.musicListData.music);
    }
  }

  pause() {
    AudioService.pause();
    setState(() {
      _breathingAnimation = "idle";
      // isStart = false;
      // isCountState = true;
    });
  }

  stop() {
    AudioService.stop();
  }

  saveTime() async {
    int timeMeditation =  min + (hour * 60);
    final FirebaseUser user = await _auth.currentUser();
    if(logTimeDocId == ""){
      DateTime today = DateTime.now();
      Firestore.instance.collection('logTime').document().setData({
        'uid': user.uid,
        'day': today.day,
        'month': today.month,
        'year': today.year,
        'time': timeMeditation
      });
    }else{
      Firestore.instance.collection('logTime').document(logTimeDocId).updateData({
        'time': (numberTrainToday + timeMeditation)
      });
    }

    Firestore.instance.collection('users').document(userDocId).updateData({
      'numberTrainToday': (numberTrainToday + timeMeditation).toString(),
      'numberTrainWeekly': (numberTrainWeekly + timeMeditation).toString(),
      'numberTrainMonthly': (numberTrainMonthly + timeMeditation).toString()
    });
  }

  getUserDocId() async {
    final FirebaseUser user = await _auth.currentUser();
    QuerySnapshot dataUsers = await Firestore.instance
        .collection('users')
        .where("uid", isEqualTo: user.uid)
        .getDocuments();
    DocumentSnapshot dataUser = dataUsers.documents[0];
    setState(() {
      userDocId = dataUser.documentID;
      numberTrainToday = int.parse(dataUser['numberTrainToday']);
      numberTrainWeekly = int.parse(dataUser['numberTrainWeekly']);
      numberTrainMonthly = int.parse(dataUser['numberTrainMonthly']);
    });

    DateTime today = DateTime.now();
    QuerySnapshot logTimeByUser = await Firestore.instance
        .collection('logTime')
        .where("uid", isEqualTo: user.uid)
        .where("day", isEqualTo: today.day)
        .where("month", isEqualTo: today.month)
        .where("year", isEqualTo: today.year)
        .getDocuments();
    if (logTimeByUser.documents.length > 0) {
      setState(() {
        logTimeDocId = logTimeByUser.documents[0].documentID;
      });
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      if (sec >= 59) {
        setState(() {
          sec = 0;
          min = min + 1;
        });
      }
      if (min >= 59) {
        setState(() {
          min = 0;
          hour = hour + 1;
        });
      }
      setState(() {
        sec = sec + 1;
      });
      /**
       * vibration
       */
      if (vibrationStatus) {
        if (sec == 1 ||
            sec == 11 ||
            sec == 22 ||
            sec == 33 ||
            sec == 44 ||
            sec == 55) {
          // หายในเข้า
          Vibration.vibrate(duration: 100);
        }
        if (sec == 4 ||
            sec == 15 ||
            sec == 26 ||
            sec == 37 ||
            sec == 48 ||
            sec == 59) {
          //หายใจออก
          Vibration.vibrate(duration: 100);
        }
      }

      /**
       * auto exit
       */
      if (autoExit) {
        Future.delayed(Duration(seconds: 2), () {
          if (AudioService.playbackState == null) {
            ProgressDialog pr = new ProgressDialog(context);
            pr.style(message: FlutterI18n.translate(context, 'saving'));
            pr.show();
            saveTime();
            Future.delayed(Duration(seconds: 2), () {
              pr.hide();
              exit(0);
            });
          }
        });
      }
    });
  }

  void getPrefrerence() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var key = "vibrationStatus";
    if (prefs.getBool(key) != null) {
      setState(() {
        vibrationStatus = prefs.getBool(key);
      });
    }
    key = "autoExit";
    if (prefs.getBool(key) != null) {
      setState(() {
        autoExit = prefs.getBool(key);
      });
    }
  }
}

// top-level static function
_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
