import 'dart:math' as math;

import 'package:flutter/material.dart';

class GradientWaveAnimation extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final double height;

  const GradientWaveAnimation({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    this.height = 220,
  });

  @override
  State<GradientWaveAnimation> createState() => _GradientWaveAnimationState();
}

class _GradientWaveAnimationState extends State<GradientWaveAnimation>
    with TickerProviderStateMixin {
  // SingleTickerProviderStateMixin -> TickerProviderStateMixin
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    // 첫 번째 물결용 컨트롤러
    _controller1 = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _animation1 = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_controller1);
    _controller1.repeat();

    // 두 번째 물결용 컨트롤러
    _controller2 = AnimationController(
      duration: const Duration(seconds: 4), // 조금 더 빠르게
      vsync: this,
    );
    _animation2 = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_controller2);
    _controller2.repeat();

    // 세 번째 물결용 컨트롤러
    _controller3 = AnimationController(
      duration: const Duration(seconds: 7), // 더 느리게
      vsync: this,
    );
    _animation3 = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_controller3);
    _controller3.repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animation1, _animation2, _animation3]),
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: GradientWavePainter(
              animation1: _animation1.value,
              animation2: _animation2.value,
              animation3: _animation3.value,
              primaryColor: widget.primaryColor.withValues(alpha: 0.4),
              secondaryColor: widget.secondaryColor.withValues(alpha: 0.2),
            ),
          );
        },
      ),
    );
  }
}

class GradientWavePainter extends CustomPainter {
  final double animation1;
  final double animation2;
  final double animation3;
  final Color primaryColor;
  final Color secondaryColor;

  GradientWavePainter({
    required this.animation1,
    required this.animation2,
    required this.animation3,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 첫 번째 물결
    _drawWave(
      canvas: canvas,
      size: size,
      amplitude: height * 0.08,
      wavelength: width * 0.8,
      phase: animation1,
      verticalPosition: height * 0.7,
      paint: Paint()..color = primaryColor,
    );

    // 두 번째 물결
    _drawWave(
      canvas: canvas,
      size: size,
      amplitude: height * 0.12,
      wavelength: width * 1.2,
      phase: animation2,
      verticalPosition: height * 0.5,
      paint: Paint()..color = secondaryColor,
    );

    // 세 번째 물결
    _drawWave(
      canvas: canvas,
      size: size,
      amplitude: height * 0.05,
      wavelength: width * 0.6,
      phase: animation3,
      verticalPosition: height * 0.9,
      paint: Paint()..color = primaryColor.withValues(alpha: 0.5),
    );
  }

  void _drawWave({
    required Canvas canvas,
    required Size size,
    required double amplitude,
    required double wavelength,
    required double phase,
    required double verticalPosition,
    required Paint paint,
  }) {
    final width = size.width;
    final path = Path();

    // 시작점
    path.moveTo(0, verticalPosition);

    // 파도의 각 지점을 그리기 - 성능을 위해 간격을 늘림
    for (double x = 0; x <= width; x += 2) {
      // 사인 함수를 이용한 y 값 계산
      final y =
          verticalPosition +
          amplitude * math.sin((2 * math.pi * x / wavelength) + phase);
      path.lineTo(x, y);
    }

    // 하단을 닫아주기
    path.lineTo(width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GradientWavePainter oldDelegate) {
    // 세 개의 애니메이션 값 중 하나라도 변경되었으면 다시 그리기
    return oldDelegate.animation1 != animation1 ||
        oldDelegate.animation2 != animation2 ||
        oldDelegate.animation3 != animation3;
  }
}
