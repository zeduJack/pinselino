import 'package:flutter/material.dart';

import '../application/coloring_controller.dart';
import '../domain/test_coloring_page.dart';
import 'coloring_canvas.dart';

class ColoringSpikeScreen extends StatefulWidget {
  const ColoringSpikeScreen({super.key});

  @override
  State<ColoringSpikeScreen> createState() => _ColoringSpikeScreenState();
}

class _ColoringSpikeScreenState extends State<ColoringSpikeScreen> {
  late final ColoringController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ColoringController(page: createTestColoringPage());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Pinselino Mal-Test'),
      backgroundColor: Colors.transparent,
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Male quer über die schwarzen Linien.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ColoringCanvas(controller: _controller),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
