import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:meditation/models/hexcode.dart';
import 'package:meditation/models/list_data.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sys_volume/flutter_volume.dart';
import 'package:meditation/theme/primary.dart';
import 'package:meditation/widgets/sliderButton.dart';
import 'package:vibration/vibration.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flare_flutter/flare_actor.dart';

AudioPlayerTask audioPlayerTask = new AudioPlayerTask();

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

  @override
  void initState() {
    super.initState();
    setState(() {
      isCountState = true;
      isStart = false;
    });
    FlutterVolume.get().then((v) {
      setState(() {
        volume = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        color: PrimaryTheme.nearlyWhite,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: VolumeWatcher(
              watcher: (vol) {
                if (vol.vol > 0.65) {
                  FlutterVolume.set(0.65);
                }
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
                              children: <Widget>[getMusicPlayer()]))
                    ]))
              ]),
            )));
  }

  Widget getMusicPlayer() {
    return Center(
        child: StreamBuilder<ScreenState>(
      stream: _screenStateStream,
      builder: (context, snapshot) {
        final screenState = snapshot.data;
        final state = screenState?.playbackState;
        final basicState = state?.basicState ?? BasicPlaybackState.none;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (basicState == BasicPlaybackState.none) ...[
              audioPlayerButton(),
            ] else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (basicState == BasicPlaybackState.playing)
                    pauseButton()
                  else if (basicState == BasicPlaybackState.paused)
                    playButton()
                  else if (basicState == BasicPlaybackState.buffering ||
                      basicState == BasicPlaybackState.skippingToNext ||
                      basicState == BasicPlaybackState.skippingToPrevious)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 64.0,
                        height: 64.0,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  stopButton(),
                ],
              ),
            stopPlayer(),
          ],
        );
      },
    ));
  }

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
              : Container()
        ],
      ),
    );
  }

  Widget stopPlayer() {
    return SliderButton(
      dismissible: false,
      height: 50,
      buttonSize: 40,
      radius: 5,
      buttonRadius: 100,
      action: () {
        setState(() {
          isCountState = true;
          isStart = false;
        });
        ProgressDialog pr = new ProgressDialog(context);
        pr.style(message: FlutterI18n.translate(context, 'saving'));
        pr.show();
        Future.delayed(Duration(seconds: 2), () {
          pr.hide();
          Navigator.pop(context);
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

  /// Encapsulate all the different data we're interested in into a single
  /// stream so we don't have to nest StreamBuilders.
  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (queue, mediaItem, playbackState) =>
              ScreenState(queue, mediaItem, playbackState));

  RaisedButton audioPlayerButton() => startButton(
        'AudioPlayer',
        () {
          AudioService.start(
            backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
            androidNotificationChannelName: 'Audio Service Demo',
            notificationColor: 0xFF2196f3,
            androidNotificationIcon: 'mipmap/ic_launcher',
            enableQueue: true,
          );
        },
      );

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

  animationStop() {
    setState(() {
      isStart = false;
      isCountState = true;
    });
  }

  RaisedButton startButton(String label, VoidCallback onPressed) =>
      RaisedButton(
        child: Text(label),
        onPressed: onPressed,
      );

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 64.0,
        onPressed: AudioService.stop,
      );
}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

class AudioPlayerTask extends BackgroundAudioTask {
  final _queue = <MediaItem>[
    MediaItem(
      id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
      album: "Science Friday",
      title: "A Salute To Head-Scratching Science",
      artist: "Science Friday and WNYC Studios",
      // duration: 5739820,
      artUri:
          "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
    )
  ];
  int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

  BasicPlaybackState _eventToBasicState(AudioPlaybackEvent event) {
    if (event.buffering) {
      return BasicPlaybackState.buffering;
    } else {
      switch (event.state) {
        case AudioPlaybackState.none:
          return BasicPlaybackState.none;
        case AudioPlaybackState.stopped:
          return BasicPlaybackState.stopped;
        case AudioPlaybackState.paused:
          return BasicPlaybackState.paused;
        case AudioPlaybackState.playing:
          return BasicPlaybackState.playing;
        case AudioPlaybackState.connecting:
          return _skipState ?? BasicPlaybackState.connecting;
        case AudioPlaybackState.completed:
          return BasicPlaybackState.stopped;
        default:
          throw Exception("Illegal state");
      }
    }
  }

  @override
  Future<void> onStart() async {
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

    AudioServiceBackground.setQueue(_queue);
    await onSkipToNext();
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    final newPos = _queueIndex + offset;
    if (!(newPos >= 0 && newPos < _queue.length)) return;
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    _queueIndex = newPos;
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    await _audioPlayer.setUrl(mediaItem.id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

  @override
  void onPlay() {
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
    }
  }

  @override
  void onSeekTo(int position) {
    _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  void onClick(MediaButton button) {
    playPause();
  }

  @override
  void onStop() {
    _audioPlayer.stop();
    _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
  }

  void _setState({@required BasicPlaybackState state, int position}) {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
    }
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
    );
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [
        // skipToPreviousControl,
        pauseControl,
        stopControl,
        // skipToNextControl
      ];
    } else {
      return [
        // skipToPreviousControl,
        playControl,
        stopControl,
        // skipToNextControl
      ];
    }
  }
}

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);
