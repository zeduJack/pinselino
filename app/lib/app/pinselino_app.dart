import 'package:flutter/material.dart';

import '../features/coloring/presentation/coloring_spike_screen.dart';

class PinselinoApp extends StatelessWidget {
  const PinselinoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pinselino',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
      scaffoldBackgroundColor: const Color(0xFFF7F4FF),
    ),
    home: const ColoringSpikeScreen(),
  );
}
