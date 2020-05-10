import 'package:flutter/material.dart';
import 'package:meditation/models/list_data.dart';
import 'package:audio_service/audio_service.dart';
import 'package:meditation/models/audio_player_task.dart';

class PlayerScreen extends StatefulWidget {
  PlayerScreen({Key key, this.musicListData}) : super(key: key);

  final MusicListData musicListData;
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    AudioService.start(
      backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
      androidNotificationChannelName: 'เจริญสติ',
      notificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      enableQueue: true,
    );
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (AudioService.running) {
      AudioService.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Example")),
      body: Center(
        child: StreamBuilder<PlaybackState>(
          stream: AudioService.playbackStateStream,
          builder: (context, snapshot) {
            final state =
                snapshot.data?.basicState ?? BasicPlaybackState.stopped;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state == BasicPlaybackState.playing)
                  RaisedButton(child: Text("Pause"), onPressed: pause)
                else
                  RaisedButton(child: Text("Play"), onPressed: play),
                if (state != BasicPlaybackState.stopped)
                  RaisedButton(child: Text("Stop"), onPressed: stop),
              ],
            );
          },
        ),
      ),
    );
  }

  play() async {
    if (AudioService.running) {
      AudioService.addQueueItem(MediaItem(
        id: widget.musicListData.music,
        album: widget.musicListData.album,
        title: widget.musicListData.title,
        artist: widget.musicListData.artist,
        artUri:widget.musicListData.imagePath,
      ));
      AudioService.playFromMediaId(widget.musicListData.music);
      AudioService.play();
    } else {
      AudioService.start(
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
        artUri:widget.musicListData.imagePath,
      ));
      AudioService.playFromMediaId(widget.musicListData.music);
      AudioService.play();
    }
  }

  pause() => AudioService.pause();
  stop() => AudioService.stop();
}

// top-level static function
_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
