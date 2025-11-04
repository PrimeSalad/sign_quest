// 🎉 final_victory.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'new_level.dart';

class FinalVictoryScreen extends StatelessWidget {
  const FinalVictoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = Random();

    return Scaffold(
      body: Stack(
        children: [
          // 🏞 Background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/gamebg.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 🏆 Victory Panel
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  "assets/images/vic.png",
                  height: size.height * 0.38,
                  fit: BoxFit.contain,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: size.height * 0.22),

                    // 🎮 Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🔁 Reload Button (fade transition)
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              _createFadeRoute(const NewLevelScreen()),
                            );
                          },
                          child: Image.asset(
                            "assets/images/reload.png",
                            height: size.height * 0.09,
                          ),
                        ),

                        SizedBox(width: size.width * 0.08),
                        // 🏠 Menu Button (fade transition)
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              _createFadeRoute(const GameScreen()),
                            );
                          },
                          child: Image.asset(
                            "assets/images/menu.png",
                            height: size.height * 0.09,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🎊 Floating Confetti Animation
          ...List.generate(25, (index) {
            final startX = random.nextDouble() * size.width;
            final endY = size.height + 100;
            final sizePx = random.nextDouble() * 12 + 6;
            final color =
                Colors.primaries[random.nextInt(Colors.primaries.length)];

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: endY),
              duration: Duration(milliseconds: 2500 + random.nextInt(1500)),
              curve: Curves.easeIn,
              builder: (context, value, child) {
                return Positioned(
                  top: value - 100,
                  left: startX,
                  child: Opacity(
                    opacity: (1 - value / endY).clamp(0.0, 1.0),
                    child: Container(
                      width: sizePx,
                      height: sizePx,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  /// 🌫 Creates a fade transition route
  PageRouteBuilder _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }
}
