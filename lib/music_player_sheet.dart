import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'music_service.dart';
import 'songs.dart';

/// مشغّل الموسيقى: قائمة أغاني + أزرار تحكم + إيكولايزر متحرك.
class MusicPlayerSheet extends StatefulWidget {
  const MusicPlayerSheet({super.key});

  @override
  State<MusicPlayerSheet> createState() => _MusicPlayerSheetState();
}

class _MusicPlayerSheetState extends State<MusicPlayerSheet>
    with SingleTickerProviderStateMixin {
  final MusicService _music = MusicService.instance;
  late final AnimationController _eqController;
  late final Animation<double> _eqAnimation;

  @override
  void initState() {
    super.initState();
    _eqController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _eqAnimation = CurvedAnimation(
      parent: _eqController,
      curve: Curves.easeInOut,
    );
    _music.isPlaying.addListener(_syncEq);
    _music.currentIndex.addListener(_onIndexChanged);
  }

  void _syncEq() {
    if (_eqAnimation.status == AnimationStatus.forward) return;
    if (_music.isPlaying.value) {
      _eqController.repeat(reverse: true);
    } else {
      _eqController.stop();
      _eqController.value = 0.2;
    }
  }

  void _onIndexChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _music.isPlaying.removeListener(_syncEq);
    _music.currentIndex.removeListener(_onIndexChanged);
    _eqController.dispose();
    super.dispose();
  }

  String _fmt(Duration? d) {
    if (d == null) return '0:00';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.72,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF80AB), Color(0xFFFF4081)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height * 0.72,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      _NowPlaying(music: _music, eq: _eqAnimation),
                      const SizedBox(height: 24),
                      _PlaybackBar(music: _music, fmt: _fmt),
                      const SizedBox(height: 24),
                      _Playlist(music: _music),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowPlaying extends StatelessWidget {
  const _NowPlaying({required this.music, required this.eq});

  final MusicService music;
  final Animation<double> eq;

  @override
  Widget build(BuildContext context) {
    final hasSongs = music.hasSongs;
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: const Icon(
            Icons.music_note_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasSongs ? music.currentSong.title : 'قائمة الأغاني',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedBuilder(
                animation: eq,
                builder: (context, child) => _Equalizer(progress: eq.value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Equalizer extends StatelessWidget {
  const _Equalizer({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final heights = [0.3, 0.8, 0.5, 1.0, 0.6];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < heights.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 4,
              height: 18 * _animate(heights[i], progress),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          progress > 0.02 ? 'تعزف الآن' : 'مستعدة',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  double _animate(double h, double p) {
    if (p <= 0.02) return 0.25;
    final wave = sin((p * 2 * pi) * 3 + h * 10).abs();
    return 0.25 + 0.75 * wave;
  }
}

class _PlaybackBar extends StatelessWidget {
  const _PlaybackBar({required this.music, required this.fmt});

  final MusicService music;
  final String Function(Duration?) fmt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<Duration?>(
          valueListenable: music.position,
          builder: (context, pos, _) {
            return ValueListenableBuilder<Duration?>(
              valueListenable: music.duration,
              builder: (context, dur, _) {
                final max = dur ?? Duration.zero;
                final value = pos == null
                    ? 0.0
                    : (max.inMilliseconds == 0
                        ? 0.0
                        : pos.inMilliseconds / max.inMilliseconds);
                return SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.2),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: value.clamp(0.0, 1.0),
                    onChanged: music.hasSongs
                        ? (v) {
                            if (dur != null) {
                              music.seek(Duration(
                                  milliseconds: (dur.inMilliseconds * v)
                                      .toInt()));
                              music.position.value = Duration(
                                  milliseconds:
                                      (dur.inMilliseconds * v).toInt());
                            }
                          }
                        : null,
                  ),
                );
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fmt(music.position.value),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                fmt(music.duration.value),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundButton(
              icon: Icons.skip_previous_rounded,
              onTap: music.hasSongs ? music.previous : null,
            ),
            const SizedBox(width: 24),
            ValueListenableBuilder<bool>(
              valueListenable: music.isPlaying,
              builder: (context, playing, _) {
                return GestureDetector(
                  onTap: music.hasSongs ? music.toggle : null,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: const Color(0xFFE91E63),
                      size: 44,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 24),
            _RoundButton(
              icon: Icons.skip_next_rounded,
              onTap: music.hasSongs ? music.next : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _Playlist extends StatelessWidget {
  const _Playlist({required this.music});

  final MusicService music;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'ضع ملفات mp3 في مجلد assets/audio\nثم أضفها في قائمة lib/songs.dart',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, height: 1.6),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'قائمة الأغاني',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<int>(
          valueListenable: music.currentIndex,
          builder: (context, current, _) {
            return Column(
              children: [
                for (var i = 0; i < songs.length; i++)
                  _SongTile(
                    song: songs[i],
                    index: i,
                    isCurrent: i == current,
                    onTap: () => music.play(i),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SongTile extends StatelessWidget {
  const _SongTile({
    required this.song,
    required this.index,
    required this.isCurrent,
    required this.onTap,
  });

  final Song song;
  final int index;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isCurrent
            ? Colors.white.withValues(alpha: 0.28)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isCurrent ? Icons.graphic_eq_rounded : Icons.music_note,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCurrent)
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}

Future<void> showMusicPlayer(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const MusicPlayerSheet(),
  );
}