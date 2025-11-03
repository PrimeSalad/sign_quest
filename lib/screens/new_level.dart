import 'package:flutter/material.dart';
import 'dart:math';
import 'game_screen.dart';
import 'final_victory.dart';

class NewLevelScreen extends StatefulWidget {
  const NewLevelScreen({super.key});

  @override
  State<NewLevelScreen> createState() => _NewLevelScreenState();
}

class _NewLevelScreenState extends State<NewLevelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _isPaused = false;
  bool _showCorrectPopup = false;
  bool _showWrongPopup = false;

  int _currentLetterIndex = 0;
  late List<String> _letters; // a-z randomized

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

    _initializeLetters();
    _generateChoices();
  }

  void _initializeLetters() {
    final random = Random();
    _letters = List.generate(26, (i) => String.fromCharCode(97 + i));
    _letters.shuffle(random); // 🔀 Randomize order
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
    _initializeLetters(); // shuffle again
    _generateChoices();
  }

  void _nextLetter() {
    if (_currentLetterIndex < _letters.length - 1) {
      setState(() => _currentLetterIndex++);
      _generateChoices();
    } else {
      _goToVictory();
    }
  }

  void _goToVictory() {
    Navigator.pushReplacement(
      context,
      _createFadeRoute(const FinalVictoryScreen()),
    );
  }

  void _showCorrect() {
    setState(() => _showCorrectPopup = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _showCorrectPopup = false);
      _nextLetter();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentLetter = _letters[_currentLetterIndex];

    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/gamebg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ⚙️ Pause/Menu button
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

                // ❓ Question mark
                Image.asset(
                  "assets/images/question.png",
                  height: size.height * 0.15,
                  fit: BoxFit.contain,
                ),

                // 🔤 Letter display (main)
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
                                  color: Colors.orangeAccent.withOpacity(0.6),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/final_$currentLetter.png", // 🅰 main image
                              height: size.height * 0.36,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 🧩 Choices (quiz)
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
                            color: Colors.black.withOpacity(0.3),
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

          // ✅ Correct Popup
          if (_showCorrectPopup)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showCorrectPopup ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset(
                      "assets/images/correct.png",
                      height: size.height * 0.35,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

          // ❌ Wrong Popup
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
                        height: size.height * 0.22,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.08),
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

          // ⏸ Pause Menu
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
