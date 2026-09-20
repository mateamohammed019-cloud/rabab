import 'dart:async';

import 'package:flutter/material.dart';

import 'photos.dart';

/// عرض دائري للصور: تُقلب تلقائيًا بلا نهاية وفي اتجاه واحد
/// (بطاقات تنزلق من اليمين لليسار) ويمكن تحريكها باليد أيضًا.
class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({
    super.key,
    this.autoFlipEvery = const Duration(seconds: 4),
  });

  final Duration autoFlipEvery;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _current = 0;

  int get _count => giftPhotos.length;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.autoFlipEvery, (_) {
      if (_count == 0 || !_controller.hasClients) return;
      _controller.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) {
      return const _CardPlaceholder();
    }
    return Column(
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _controller,
            itemCount: null, // دوران لا نهائي في اتجاه واحد
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final photoIndex = index % _count;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _PhotoCard(index: photoIndex),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _current % _count ? 26 : 9,
                height: 9,
                decoration: BoxDecoration(
                  color: i == _current % _count
                      ? const Color(0xFFD81B60)
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88004F).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          giftPhotos[index],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.white.withValues(alpha: 0.5),
              child: const Center(
                child: Icon(
                  Icons.photo_library_outlined,
                  color: Color(0x88D81B60),
                  size: 48,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: Text(
          'لا توجد صور بعد',
          style: TextStyle(color: Color(0xFF88004F)),
        ),
      ),
    );
  }
}