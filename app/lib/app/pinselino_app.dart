import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/coloring/application/progress_store.dart';
import '../features/coloring/infrastructure/shared_preferences_progress_store.dart';
import '../features/coloring/presentation/motif_gallery_screen.dart';

class PinselinoApp extends StatelessWidget {
  const PinselinoApp({super.key, this.progressStore});

  final ProgressStore? progressStore;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pinselino',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
      scaffoldBackgroundColor: const Color(0xFFF7F4FF),
    ),
    home: progressStore == null
        ? const _PersistentHome()
        : MotifGalleryScreen(progressStore: progressStore!),
  );
}

class _PersistentHome extends StatefulWidget {
  const _PersistentHome();

  @override
  State<_PersistentHome> createState() => _PersistentHomeState();
}

class _PersistentHomeState extends State<_PersistentHome> {
  late final Future<ProgressStore> _store = SharedPreferences.getInstance()
      .then(SharedPreferencesProgressStore.new);

  @override
  Widget build(BuildContext context) => FutureBuilder<ProgressStore>(
    future: _store,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return MotifGalleryScreen(progressStore: snapshot.requireData);
    },
  );
}
