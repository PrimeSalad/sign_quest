import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart'; // for SystemNavigator.pop if needed
import 'screens/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _initBgm();
  }

  Future<void> _initBgm() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setSource(
        AssetSource('music/bgm.mp3'),
      ); // 🎵 your file path
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.resume();
      debugPrint('✅ BGM is playing...');
    } catch (e) {
      debugPrint('❌ Error playing BGM: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 🔄 Handle pause/resume when app goes background/foreground
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Quest - Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.black87),
      ),
      home: const GameScreen(),
    );
  }
}
