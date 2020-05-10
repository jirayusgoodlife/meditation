import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:audio_service/audio_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meditation/models/hexcode.dart';
import 'package:meditation/models/list_data.dart';
import 'dart:async';
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

final FirebaseAuth _auth = FirebaseAuth.instance;

class PlayerScreen extends StatefulWidget {
  PlayerScreen({Key key, this.musicListData}) : super(key: key);
  final MusicListData musicListData;
  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  double volume = 0;

  String _countdownAnimation = "countdown"; // idle , countdown
  String _breathingAnimation = "breathing"; // idle , breathing

  bool isCountState = true;
  bool isStart = false;
  bool isPlayer = false;

  Timer _timer;
  int sec = 0;
  int min = 0;
  int hour = 0;
  String userDocId = "";
  int numberTrainToday = 0;
  int numberTrainWeekly = 0;
  int numberTrainMonthly = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      isCountState = true;
      isStart = false;
      isPlayer = false;
    });

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

    if (AudioService.playbackState != null &&
        AudioService.playbackState.basicState == BasicPlaybackState.playing) {
      animationCountToBreath();
      isPlayer = true;
    }

    getUserDocId();
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
              ? isCountState
                  ? Container(
                      width: 80,
                      child: FlareActor(
                        "assets/animation/nab3wi.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        animation: _countdownAnimation,
                      ))
                  : FlareActor(
                      "assets/animation/haayai.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: _breathingAnimation,
                    )
              : Container(),
          GestureDetector(
              onTap: () {
                setState(() {
                  isPlayer = true;
                });
                if (isPlayer) {
                  play();
                  startTimer();
                } else {
                  //pause();
                }
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
          isCountState = true;
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

  animationCountToBreath() {
    setState(() {
      isStart = true;
    });
    Future.delayed(Duration(microseconds: 4500), () {
      setState(() {
        isCountState = false;
      });
    });
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
      AudioService.playFromMediaId(widget.musicListData.music);
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
      AudioService.playFromMediaId(widget.musicListData.music);
    }
    animationCountToBreath();
  }

  pause() {
    AudioService.pause();
    setState(() {
      isStart = false;
      isCountState = true;
    });
  }

  stop() {
    AudioService.stop();
  }

  saveTime() async {
    int timeMeditation = min + (hour * 60);
    print('$timeMeditation');
    print('$userDocId');
    // TODO : insert logTime
    Firestore.instance.collection('users').document(userDocId).updateData({
      'numberTrainToday': (numberTrainToday + timeMeditation).toString(),
      'numberTrainWeekly': (numberTrainWeekly + timeMeditation).toString(),
      'numberTrainMonthly': (numberTrainMonthly + timeMeditation).toString()
    });
    
  }

  getUserDocId() async {
    final FirebaseUser user = await _auth.currentUser();
    Firestore.instance
        .collection('users')
        .where("uid", isEqualTo: user.uid)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) {
        setState(() {
          userDocId = doc.documentID;
          numberTrainToday = int.parse(doc['numberTrainToday']);
          numberTrainWeekly = int.parse(doc['numberTrainWeekly']);
          numberTrainMonthly = int.parse(doc['numberTrainMonthly']);
        });
      });
    });
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
    });
  }
}

// top-level static function
_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
