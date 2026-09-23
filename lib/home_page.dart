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
                child: Padding(
                  // مساحة محجوزة حتى لا يغطي زر الموسيقى الصور
                  padding: const EdgeInsets.only(bottom: 96),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final h = constraints.maxHeight;
                      final headerH = h * 0.40;
                      return Column(
                        children: [
                          SizedBox(
                            height: headerH,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topCenter,
                              child: const _Header(),
                            ),
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const PhotoCarousel(),
                            ),
                          ),
                        ],
                      );
                    },
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BeatingHeart(size: 52),
          const SizedBox(height: 6),
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
                fontSize: 64,
                letterSpacing: 2,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color(0xFFD81B60).withValues(alpha: 0.45),
                    blurRadius: 18,
                  ),
                  Shadow(
                    color: const Color(0xFFFF5C8A).withValues(alpha: 0.6),
                    blurRadius: 34,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Text(
              'هدية خاصة لكِ 🎀',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF88004F),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              'إهداء إلى أجمل باش مهندسة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF8E1E4B),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'نجكلي من هنا لعند طبرق',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Color(0xFFC2185B),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeatingHeart extends StatefulWidget {
  const _BeatingHeart({this.size = 64});

  final double size;

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
            size: widget.size,
            color: color,
            shadows: [
              Shadow(
                color: color.withValues(alpha: 0.55),
                blurRadius: 16 * widget.size / 64 + 14 * t,
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