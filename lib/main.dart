import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const RababApp());
}

class RababApp extends StatelessWidget {
  const RababApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رباب',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFFFF80AB),
        ),
        fontFamilyFallback: ['Segoe UI', 'Arial'],
      ),
      home: const HomePage(),
    );
  }
}