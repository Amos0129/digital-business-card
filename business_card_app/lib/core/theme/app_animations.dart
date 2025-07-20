// lib/core/theme/app_animations.dart
import 'package:flutter/material.dart';

/// 應用程式動畫配置
/// 
/// 提供一致的動畫時長、曲線和預設動畫
/// 創造流暢的用戶體驗
class AppAnimations {
  // 防止實例化
  AppAnimations._();

  // ========== 動畫時長 ==========
  /// 極快動畫 (100ms)
  static const Duration durationFast = Duration(milliseconds: 100);
  
  /// 快速動畫 (200ms)
  static const Duration durationQuick = Duration(milliseconds: 200);
  
  /// 標準動畫 (300ms)
  static const Duration durationNormal = Duration(milliseconds: 300);
  
  /// 慢動畫 (500ms)
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  /// 極慢動畫 (800ms)
  static const Duration durationVerySlow = Duration(milliseconds: 800);

  // ========== 動畫曲線 ==========
  /// 標準緩動
  static const Curve curveStandard = Curves.easeInOut;
  
  /// 強調緩動
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  
  /// 減速緩動
  static const Curve curveDecelerated = Curves.easeOut;
  
  /// 加速緩動
  static const Curve curveAccelerated = Curves.easeIn;
  
  /// 彈性緩動
  static const Curve curveElastic = Curves.elasticOut;
  
  /// 彈跳緩動
  static const Curve curveBounce = Curves.bounceOut;

  // ========== 頁面轉場動畫 ==========
  /// 滑入轉場
  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    required RouteSettings settings,
    Offset beginOffset = const Offset(1.0, 0.0),
    Duration duration = durationNormal,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curveEmphasized,
        ));
        
        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }
  
  /// 淡入轉場
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    required RouteSettings settings,
    Duration duration = durationNormal,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: curveStandard,
          ),
          child: child,
        );
      },
    );
  }
  
  /// 縮放轉場
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    required RouteSettings settings,
    Duration duration = durationNormal,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curveEmphasized,
        ));
        
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curveStandard,
        ));
        
        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  // ========== 組件動畫 ==========
  /// 按鈕點擊動畫
  static Widget createButtonPressAnimation({
    required Widget child,
    required VoidCallback? onPressed,
    Duration duration = durationFast,
    double scaleValue = 0.95,
  }) {
    return _AnimatedButton(
      onPressed: onPressed,
      duration: duration,
      scaleValue: scaleValue,
      child: child,
    );
  }
  
  /// 卡片浮起動畫
  static Widget createCardHoverAnimation({
    required Widget child,
    Duration duration = durationQuick,
    double elevation = 8.0,
  }) {
    return _AnimatedCard(
      duration: duration,
      elevation: elevation,
      child: child,
    );
  }
  
  /// 列表項目進入動畫
  static Widget createListItemAnimation({
    required Widget child,
    required int index,
    Duration duration = durationNormal,
    Duration delay = const Duration(milliseconds: 50),
  }) {
    return _AnimatedListItem(
      index: index,
      duration: duration,
      delay: delay,
      child: child,
    );
  }

  // ========== 載入動畫 ==========
  /// 脈衝動畫
  static Widget createPulseAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1200),
    double minOpacity = 0.3,
    double maxOpacity = 1.0,
  }) {
    return _PulseAnimation(
      duration: duration,
      minOpacity: minOpacity,
      maxOpacity: maxOpacity,
      child: child,
    );
  }
  
  /// 旋轉載入動畫
  static Widget createRotationAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return _RotationAnimation(
      duration: duration,
      child: child,
    );
  }
  
  /// 波浪載入動畫
  static Widget createWaveAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    Color color = Colors.blue,
  }) {
    return _WaveAnimation(
      duration: duration,
      color: color,
      child: child,
    );
  }

  // ========== 交錯動畫 ==========
  /// 創建交錯動畫控制器
  static AnimationController createStaggeredController({
    required TickerProvider vsync,
    Duration duration = durationSlow,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }
  
  /// 創建交錯動畫間隔
  static Interval createStaggeredInterval({
    required int index,
    required int totalItems,
    double startOffset = 0.0,
    double endOffset = 1.0,
  }) {
    final itemDuration = (endOffset - startOffset) / totalItems;
    final start = startOffset + (index * itemDuration);
    final end = (start + itemDuration).clamp(0.0, 1.0);
    
    return Interval(start, end, curve: curveEmphasized);
  }
}

// ========== 私有動畫組件 ==========

/// 動畫按鈕組件
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleValue;
  
  const _AnimatedButton({
    required this.child,
    required this.onPressed,
    required this.duration,
    required this.scaleValue,
  });
  
  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.curveStandard,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// 動畫卡片組件
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double elevation;
  
  const _AnimatedCard({
    required this.child,
    required this.duration,
    required this.elevation,
  });
  
  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: AppAnimations.curveStandard,
        decoration: BoxDecoration(
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    offset: const Offset(0, widget.elevation),
                    blurRadius: widget.elevation * 2,
                    spreadRadius: 0,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}

/// 動畫列表項目組件
class _AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delay;
  
  const _AnimatedListItem({
    required this.child,
    required this.index,
    required this.duration,
    required this.delay,
  });
  
  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.curveEmphasized,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.curveStandard,
    ));
    
    // 延遲啟動動畫
    Future.delayed(
      Duration(milliseconds: widget.index * widget.delay.inMilliseconds),
      () => _controller.forward(),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// 脈衝動畫組件
class _PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;
  
  const _PulseAnimation({
    required this.child,
    required this.duration,
    required this.minOpacity,
    required this.maxOpacity,
  });
  
  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.curveStandard,
    ));
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// 旋轉動畫組件
class _RotationAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const _RotationAnimation({
    required this.child,
    required this.duration,
  });
  
  @override
  State<_RotationAnimation> createState() => _RotationAnimationState();
}

class _RotationAnimationState extends State<_RotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: widget.child,
    );
  }
}

/// 波浪動畫組件
class _WaveAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color color;
  
  const _WaveAnimation({
    required this.child,
    required this.duration,
    required this.color,
  });
  
  @override
  State<_WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<_WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(
            animationValue: _controller.value,
            color: widget.color,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 波浪繪製器
class _WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  
  _WavePainter({
    required this.animationValue,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final amplitude = size.height * 0.1;
    final frequency = 2.0;
    final phase = animationValue * 2 * 3.14159;
    
    path.moveTo(0, size.height * 0.5);
    
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.5 + 
          amplitude * math.sin(frequency * x / size.width * 2 * 3.14159 + phase);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}