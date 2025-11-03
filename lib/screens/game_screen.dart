import 'package:flutter/material.dart';
import '../widgets/play_button.dart';
import 'level_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  void _navigateToLevelScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const LevelScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 🔹 Pure black fade transition
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        opaque: true,
        barrierColor: Colors.black, // para solid black yung transition
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoHeight = size.height * 0.22;
    final playSize = size.width * 0.33;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),
                ),

                const Spacer(flex: 1),

                // Play button
                PlayButton(
                  size: playSize,
                  onPressed: () => _navigateToLevelScreen(context),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
