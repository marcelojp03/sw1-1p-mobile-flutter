import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';

enum BackgroundStyle { surface, aurora }

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final BackgroundStyle style;
  final bool animated;
  final Duration animationDuration;
  final double intensity;
  final bool showParticles;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.style = BackgroundStyle.surface,
    this.animated = true,
    this.animationDuration = const Duration(seconds: 8),
    this.intensity = 0.7,
    this.showParticles = false,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Gradient _getGradient(bool isDark) {
    switch (widget.style) {
      case BackgroundStyle.surface:
        return isDark
            ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B1020), Color(0xFF0F172A)],
            )
            : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0E7FF), Color(0xFFF8FAFC), Color(0xFFF5F3FF)],
              stops: [0.0, 0.5, 1.0],
            );
      case BackgroundStyle.aurora:
        return isDark
            ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E1B4B),
                Color(0xFF164E63),
                Color(0xFF3730A3),
                Color(0xFF0F172A),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            )
            : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFDDD6FE),
                Color(0xFFBAE6FD),
                Color(0xFFF8FAFC),
                Color(0xFFF5F3FF),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentGradient = _getGradient(isDark);
    final bool reduce = MediaQuery.of(context).disableAnimations;
    final bool shouldAnimate = widget.animated && !reduce;

    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }

    return Container(
      decoration: BoxDecoration(gradient: currentGradient),
      child: Stack(
        children: [
          if (shouldAnimate)
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        -1.0 + 2.0 * _rotationAnimation.value,
                        -1.0 + 2.0 * _rotationAnimation.value,
                      ),
                      radius: 2.0,
                      colors: [
                        currentGradient.colors.first.withOpacity(
                          widget.intensity * 0.3,
                        ),
                        currentGradient.colors.last.withOpacity(
                          widget.intensity * 0.1,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),
          if (widget.showParticles) ..._buildParticles(),
          widget.child,
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    final res = context.responsive;
    return List.generate(8, (index) {
      final delay = index * 200;
      return Positioned(
        left: res.wp(10) + (index * res.wp(8)) % res.wp(60),
        top: res.hp(12) + (index * res.hp(10)) % res.hp(70),
        child: Container(
              width: res.dp(0.4) + (index % 3) * res.dp(0.2),
              height: res.dp(0.4) + (index % 3) * res.dp(0.2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .moveY(
              delay: delay.ms,
              duration: (3000 + index * 500).ms,
              begin: 0,
              end: -50,
              curve: Curves.easeInOut,
            )
            .then()
            .moveY(
              duration: (3000 + index * 500).ms,
              begin: -50,
              end: 0,
              curve: Curves.easeInOut,
            )
            .fadeIn(delay: delay.ms, duration: 1000.ms)
            .then()
            .fadeOut(duration: 1000.ms),
      );
    });
  }
}
