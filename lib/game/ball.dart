import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/constants.dart';

class Ball extends PositionComponent {
  Color color;
  double velocityY = 0;
  bool isAlive = true;
  bool isGrounded = false;

  // Trail effect
  final List<Offset> _trail = [];
  static const int _maxTrailLength = 12;

  Ball({required Vector2 position, required this.color})
      : super(
          position: position,
          size: Vector2.all(AppConstants.ballRadius * 2),
          anchor: Anchor.center,
        );

  void jump() {
    velocityY = AppConstants.jumpVelocity;
  }

  void bounce() {
    velocityY = AppConstants.ballBounceVelocity;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isAlive) return;

    // Apply gravity
    velocityY += AppConstants.gravity * dt;
    position.y += velocityY * dt;

    // Save trail position
    _trail.add(Offset(position.x, position.y));
    if (_trail.length > _maxTrailLength) {
      _trail.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isAlive) return;

    // Draw trail
    for (int i = 0; i < _trail.length - 1; i++) {
      final opacity = (i / _trail.length) * 0.4;
      final trailRadius = AppConstants.ballRadius * (i / _trail.length) * 0.8;
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(_trail[i].dx - position.x + AppConstants.ballRadius,
            _trail[i].dy - position.y + AppConstants.ballRadius),
        trailRadius,
        paint,
      );
    }

    // Draw glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(
      Offset(AppConstants.ballRadius, AppConstants.ballRadius),
      AppConstants.ballRadius + 5,
      glowPaint,
    );

    // Draw ball
    final ballPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(AppConstants.ballRadius, AppConstants.ballRadius),
      AppConstants.ballRadius,
      ballPaint,
    );

    // Draw shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(AppConstants.ballRadius - 8, AppConstants.ballRadius - 8),
      AppConstants.ballRadius * 0.25,
      shinePaint,
    );
  }

  // Returns ball's circular hit area
  bool collidesWithRect(Rect rect) {
    final center = Offset(position.x, position.y);
    final closestX = max(rect.left, min(center.dx, rect.right));
    final closestY = max(rect.top, min(center.dy, rect.bottom));
    final distance = (center - Offset(closestX, closestY)).distance;
    return distance <= AppConstants.ballRadius;
  }
}
