import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'songs.dart';

/// خدمة تشغيل الموسيقى: كائن واحد يعيش طوال عمر التطبيق
/// حتى تبقى الموسيقى تعمل في الخلفية أثناء تصفح الصور.
class MusicService {
  MusicService._();

  static final MusicService instance = MusicService._();

  final AudioPlayer _player = AudioPlayer();
  int _currentIndex = 0;

  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<int> currentIndex = ValueNotifier(0);
  final ValueNotifier<Duration?> position = ValueNotifier(null);
  final ValueNotifier<Duration?> duration = ValueNotifier(null);

  bool get hasSongs => songs.isNotEmpty;

  Song get currentSong => songs[_currentIndex];

  void init() {
    _player.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });
    _player.onPositionChanged.listen((d) => position.value = d);
    _player.onDurationChanged.listen((d) => duration.value = d);
    _player.onPlayerComplete.listen((_) {
      _playNext(auto: true);
    });
  }

  Future<void> play(int index) async {
    if (songs.isEmpty) return;
    _currentIndex = index % songs.length;
    currentIndex.value = _currentIndex;
    await _player.stop();
    await _player.play(
      AssetSource(songs[_currentIndex].file.replaceFirst('assets/', '')),
      mode: PlayerMode.mediaPlayer,
    );
  }

  Future<void> toggle() async {
    if (songs.isEmpty) return;
    if (isPlaying.value) {
      await _player.pause();
    } else {
      if (position.value == null || position.value == Duration.zero) {
        await play(_currentIndex);
      } else {
        await _player.resume();
      }
    }
  }

  Future<void> next() async => _playNext(auto: false);

  Future<void> previous() async {
    if (_currentIndex == 0) return;
    await play(_currentIndex - 1);
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> stopAndReset() async {
    await _player.stop();
    isPlaying.value = false;
    position.value = null;
    duration.value = null;
  }

  Future<void> _playNext({required bool auto}) async {
    if (songs.isEmpty) return;
    final nextIndex = (_currentIndex + 1) % songs.length;
    await play(nextIndex);
  }
}