import 'package:flutter/material.dart';
import 'heart_rain.dart';
import 'music_player_sheet.dart';
import 'music_service.dart';
import 'photo_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    MusicService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFF6F91),
                    Color(0xFFFFC3A0),
                    Color(0xFFFFF3E0),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        const _Header(),
                        const SizedBox(height: 28),
                        const PhotoCarousel(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: HeartRain(amount: 45)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _MusicButton(
                  onTap: () => showMusicPlayer(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BeatingHeart(),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD3E0),
              Color(0xFFFF5C8A),
              Color(0xFFB71C1C),
            ],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'رباب',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'ArefRuqaa',
              fontSize: 84,
              letterSpacing: 2,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: const Color(0xFFD81B60).withValues(alpha: 0.45),
                  blurRadius: 22,
                ),
                Shadow(
                  color: const Color(0xFFFF5C8A).withValues(alpha: 0.6),
                  blurRadius: 40,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Text(
            'هدية خاصة لكِ 🎀',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF88004F),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'كل لحظة معكِ أجمل من أي زهور.. هذه الصور تذكار جميل لما يملأ قلبي بكِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Color(0xFF8E1E4B),
          ),
        ),
      ],
    );
  }
}

class _BeatingHeart extends StatefulWidget {
  const _BeatingHeart();

  @override
  State<_BeatingHeart> createState() => _BeatingHeartState();
}

class _BeatingHeartState extends State<_BeatingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final color = Color.lerp(
          const Color(0xFFFFA7C4), // وردي فاتح
          const Color(0xFFD50000), // أحمر
          t,
        )!;
        return Transform.scale(
          scale: 1.0 + 0.3 * t,
          child: Icon(
            Icons.favorite_rounded,
            size: 64,
            color: color,
            shadows: [
              Shadow(
                color: color.withValues(alpha: 0.55),
                blurRadius: 16 + 14 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MusicButton extends StatelessWidget {
  const _MusicButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE91E63).withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'الموسيقى',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}