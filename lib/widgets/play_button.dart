import 'package:flutter/material.dart';

class PlayButton extends StatefulWidget {
  final double size;
  final VoidCallback onPressed;
  const PlayButton({super.key, required this.size, required this.onPressed});

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.08)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.08, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50),
    ]).animate(_pulseController);

    _pulseController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: _pressed ? 0.94 : 1.0,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Image.asset('assets/images/play2.png', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
