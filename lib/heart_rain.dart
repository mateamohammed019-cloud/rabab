import 'dart:math';

import 'package:flutter/material.dart';

/// تأثير مطر القلوب: قلوب تسقط من أعلى الشاشة باستمرار.
class HeartRain extends StatefulWidget {
  const HeartRain({super.key, this.amount = 18});

  final int amount;

  @override
  State<HeartRain> createState() => _HeartRainState();
}

class _HeartRainState extends State<HeartRain> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_FallingHeart> _hearts;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _hearts = List.generate(widget.amount, (_) => _FallingHeart(_random));
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
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (final heart in _hearts)
                  Positioned(
                    left: heart.dx * constraints.maxWidth,
                    top: (_controller.value + heart.offset) % 1.0 *
                        constraints.maxHeight,
                    child: Opacity(
                      opacity: heart.opacity,
                      child: Transform.rotate(
                        angle: heart.rotation,
                        child: Icon(
                          Icons.favorite_rounded,
                          size: heart.size,
                          color: heart.color,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FallingHeart {
  _FallingHeart(Random random)
      : dx = random.nextDouble(),
        offset = random.nextDouble(),
        size = 18 + random.nextDouble() * 26,
        opacity = 0.25 + random.nextDouble() * 0.5,
        rotation = random.nextDouble() * 2 * pi,
        color = const Color(0xFFE91E63).withValues(
          alpha: 0.55 + random.nextDouble() * 0.45,
        );

  final double dx;
  final double offset;
  final double size;
  final double opacity;
  final double rotation;
  final Color color;
}