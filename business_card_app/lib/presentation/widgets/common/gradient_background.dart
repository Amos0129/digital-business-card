// lib/presentation/widgets/common/gradient_background.dart
import 'package:flutter/material.dart';

/// 漸層背景元件
/// 
/// 提供統一的漸層背景效果
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColors = [
      const Color(0xFF2196F3),
      const Color(0xFF21CBF3),
      const Color(0xFF64B5F6),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ?? defaultColors,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// 特殊效果的漸層背景
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF2196F3),
                  const Color(0xFF64B5F6),
                  _animation.value,
                )!,
                Color.lerp(
                  const Color(0xFF21CBF3),
                  const Color(0xFF2196F3),
                  _animation.value,
                )!,
                Color.lerp(
                  const Color(0xFF64B5F6),
                  const Color(0xFF21CBF3),
                  _animation.value,
                )!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}