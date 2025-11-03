import 'package:flutter/material.dart';
import 'dart:math';
import 'game_screen.dart';
import 'victory_screen.dart'; // ✅ Added

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _isPaused = false;
  bool _showCorrectPopup = false;
  bool _showWrongPopup = false;

  int _currentLetterIndex = 0;
  final List<String> _letters =
      List.generate(26, (i) => String.fromCharCode(97 + i)); // a-z

  List<String> _choices = [];
  late String _correctChoice;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _generateChoices();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _controller.stop();
      } else {
        _controller.repeat(reverse: true);
      }
    });
  }

  void _restartGame() {
    setState(() {
      _isPaused = false;
      _currentLetterIndex = 0;
      _showCorrectPopup = false;
      _showWrongPopup = false;
    });
    _controller.reset();
    _controller.repeat(reverse: true);
    _generateChoices();
  }

  void _nextLetter() {
    if (_currentLetterIndex < 25) {
      setState(() => _currentLetterIndex++);
      _generateChoices();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VictoryScreen()),
      );
    }
  }

  void _showCorrect() {
    setState(() => _showCorrectPopup = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _showCorrectPopup = false);
      if (_currentLetterIndex == 25) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VictoryScreen()),
        );
      } else {
        _nextLetter();
      }
    });
  }

  void _generateChoices() {
    final random = Random();
    final currentLetter = _letters[_currentLetterIndex];
    _correctChoice = "assets/images/quiz_$currentLetter.png";

    final wrongLetters = _letters.where((l) => l != currentLetter).toList()
      ..shuffle(random);
    final wrongChoices = wrongLetters.take(2).toList();

    _choices = [
      _correctChoice,
      "assets/images/quiz_${wrongChoices[0]}.png",
      "assets/images/quiz_${wrongChoices[1]}.png",
    ]..shuffle(random);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentLetter = _letters[_currentLetterIndex];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/gamebg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28, right: 16),
                    child: GestureDetector(
                      onTap: _togglePause,
                      child: Image.asset(
                        "assets/images/menu.png",
                        height: size.height * 0.07,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Image.asset(
                  "assets/images/question.png",
                  height: size.height * 0.15,
                  fit: BoxFit.contain,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.04),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: RotationTransition(
                          turns: _rotationAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.6),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/$currentLetter.png",
                              height: size.height * 0.36,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.035),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _choices.map((assetPath) {
                      return GestureDetector(
                        onTap: _isPaused
                            ? null
                            : () {
                                if (assetPath == _correctChoice) {
                                  _showCorrect();
                                } else {
                                  setState(() => _showWrongPopup = true);
                                  _controller.stop();
                                }
                              },
                        child: Container(
                          width: size.width * 0.23,
                          height: size.height * 0.11,
                          decoration: BoxDecoration(
                            color: Colors.green.shade900.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              assetPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (_showCorrectPopup)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(20, (index) {
                      final random = Random();
                      final dx = (random.nextDouble() * 2 - 1) * 200;
                      final dy = (random.nextDouble() * 2 - 1) * 200;
                      final sizePx = random.nextDouble() * 10 + 5;
                      final color = Colors
                          .primaries[random.nextInt(Colors.primaries.length)];

                      return TweenAnimationBuilder<Offset>(
                        tween: Tween<Offset>(
                          begin: Offset.zero,
                          end: Offset(dx, dy),
                        ),
                        duration: const Duration(milliseconds: 700),
                        builder: (context, offset, child) {
                          double opacity = 1 - (offset.distance / 200);
                          opacity = opacity.clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: offset,
                            child: Opacity(
                              opacity: opacity,
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
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        "assets/images/correct.png",
                        height: size.height * 0.35,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_showWrongPopup)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/images/nt.png",
                        height: size.height * 0.27,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.04),
                        child: GestureDetector(
                          onTap: () {
                            _restartGame();
                            setState(() => _showWrongPopup = false);
                          },
                          child: Image.asset(
                            "assets/images/reload.png",
                            height: size.height * 0.10,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isPaused)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/images/pausecont.png",
                        height: size.height * 0.25,
                        fit: BoxFit.contain,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: size.height * 0.045),
                          // Buttons in a single row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: _togglePause,
                                child: Image.asset(
                                  "assets/images/play.png",
                                  height: size.height * 0.085,
                                ),
                              ),
                              SizedBox(width: size.width * 0.01),
                              GestureDetector(
                                onTap: _restartGame,
                                child: Image.asset(
                                  "assets/images/reload.png",
                                  height: size.height * 0.075,
                                ),
                              ),
                              SizedBox(width: size.width * 0.04),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const GameScreen(),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  "assets/images/menu2.png",
                                  height: size.height * 0.075,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
