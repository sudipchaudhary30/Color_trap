import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ParticleEffect extends PositionComponent {
  final Color color;
  final List<_Particle> _particles = [];
  double _lifetime = 0;
  static const double _maxLifetime = 0.8;
  final Random _random = Random();

  ParticleEffect({required Vector2 position, required this.color})
      : super(position: position) {
    // Spawn particles
    for (int i = 0; i < 16; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 80 + _random.nextDouble() * 180;
      _particles.add(_Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        radius: 3 + _random.nextDouble() * 5,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    if (_lifetime >= _maxLifetime) {
      removeFromParent();
      return;
    }
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 300 * dt; // gravity on particles
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _lifetime / _maxLifetime;
    for (final p in _particles) {
      final paint = Paint()
        ..color = color.withOpacity((1 - progress).clamp(0, 1))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(p.x, p.y), p.radius * (1 - progress * 0.5), paint);
    }
  }
}

class _Particle {
  double x = 0, y = 0;
  double vx, vy;
  double radius;
  _Particle({required this.vx, required this.vy, required this.radius});
}
