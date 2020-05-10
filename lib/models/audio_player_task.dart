import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:async';

import 'package:flutter/material.dart';

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

class AudioPlayerTask extends BackgroundAudioTask {
  var _mediaItems = <String, MediaItem>{};
  var _queue = <MediaItem>[];
  final _audioPlayer = AudioPlayer();
  final _completer = Completer();

  bool _playing;
  int _queueIndex = -1;
  bool get hasNext => _queueIndex + 1 < _queue.length;
  bool get hasPrevious => _queueIndex > 0;
  MediaItem get mediaItem => _queue[_queueIndex];

  // map just audio plugin with audio service
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
          return BasicPlaybackState.connecting;
        case AudioPlaybackState.completed:
          return BasicPlaybackState.stopped;
        default:
          throw Exception("Illegal state");
      }
    }
  }

  @override
  Future<void> onStart() async {
    await _completer.future;
    AudioServiceBackground.setState(
        controls: [], basicState: BasicPlaybackState.playing);
  }

  @override
  Future<void> onStop() async {
    if (_audioPlayer.playbackState != AudioPlaybackState.none) {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
    }
    _playing = false;
    _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
  }

  @override
  void onPlay() async {
    _playing = true;
    _setState(state: BasicPlaybackState.playing);    
    await _audioPlayer.play();
  }

  @override
  void onPause() async {
    _playing = false;
    _setState(state: BasicPlaybackState.paused);   
    await _audioPlayer.pause();
  }

  @override
  void onAddQueueItem(MediaItem item) {
    _mediaItems[item.id] = item;
    _queue.clear();
    _mediaItems.forEach((key, value) {
      _queue.add(value);
    });
    AudioServiceBackground.setQueue(_queue);
  }

  @override
  void onPlayFromMediaId(String mediaId) async {
    // play the item at mediaItems[mediaId]
    AudioServiceBackground.setMediaItem(_mediaItems[mediaId]);
    await _audioPlayer.setUrl(_mediaItems[mediaId].id);    
     _playing = true;
    _setState(state: BasicPlaybackState.playing);    
    await _audioPlayer.play();
  }

  void _setState({@required BasicPlaybackState state}) {
    AudioServiceBackground.setState(
      controls: getControls(state),
      basicState: state,
    );
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [pauseControl];
    } else {
      return [playControl];
    }
  }
}
