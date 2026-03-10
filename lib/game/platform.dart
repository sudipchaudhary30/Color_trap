import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ColorPlatform extends PositionComponent {
  final List<Color> colors;
  Color _ballColor;
  late List<Color> _sideColors; // [top, right, bottom, left]

  final Random _random = Random();

  double _currentAngle = 0;
  double _startAngle = 0;
  double _targetAngle = 0;
  double _rotationProgress = 0;
  double _rotationDuration = 0.18;
  bool _isRotating = false;
  int _rotationDirection = 0;

  double _hitPulseTimer = 0;
  double _missShakeTimer = 0;
  double _shakePhase = 0;
  static const double _hitPulseDuration = 0.14;
  static const double _missShakeDuration = 0.22;

  ColorPlatform({
    required Vector2 position,
    required this.colors,
    required Color ballColor,
    required double screenWidth,
  })  : _ballColor = ballColor,
        super(
          position: position,
          size: Vector2.all(screenWidth * 0.48),
          anchor: Anchor.center,
        ) {
    _generateSides();
  }

  Color get topColor => _sideColors[0];

  void _generateSides() {
    final shuffled = List<Color>.from(colors)..shuffle(_random);
    _sideColors = shuffled.take(4).toList();
  }

  void rotateLeft() {
    if (_isRotating) return;
    _startAngle = _currentAngle;
    _targetAngle = _currentAngle - pi / 2;
    _rotationProgress = 0;
    _isRotating = true;
    _rotationDirection = -1;
  }

  void rotateRight() {
    if (_isRotating) return;
    _startAngle = _currentAngle;
    _targetAngle = _currentAngle + pi / 2;
    _rotationProgress = 0;
    _isRotating = true;
    _rotationDirection = 1;
  }

  void randomizeSides() {
    final top = _sideColors[0];
    final others = _sideColors.sublist(1)..shuffle(_random);
    _sideColors = [top, ...others];
  }

  void increaseDifficulty(int score) {
    final next = 0.18 - score * 0.003;
    _rotationDuration = next.clamp(0.09, 0.18);
  }

  void updateBallColor(Color ballColor) {
    _ballColor = ballColor;
  }

  int get _matchIndex {
    final index = _sideColors.indexOf(_ballColor);
    return index >= 0 ? index : 0;
  }

  void triggerHitPulse() {
    _hitPulseTimer = _hitPulseDuration;
  }

  void triggerMissShake() {
    _missShakeTimer = _missShakeDuration;
    _shakePhase = 0;
  }

  Color? colorAtWorldPoint(Offset worldPoint) {
    final edge = size.x;

    final localX = worldPoint.dx - (position.x - edge / 2);
    final localY = worldPoint.dy - (position.y - edge / 2);

    if (localX < 0 || localX > edge || localY < 0 || localY > edge) {
      return null;
    }

    final cx = edge / 2;
    final cy = edge / 2;

    final dx = localX - cx;
    final dy = localY - cy;

    // Unrotate the contact point into the square's logical orientation.
    final c = cos(_currentAngle);
    final s = sin(_currentAngle);
    final unrotX = dx * c + dy * s + cx;
    final unrotY = -dx * s + dy * c + cy;

    if (unrotY <= unrotX && unrotY <= (-unrotX + edge)) {
      return _sideColors[0]; // top triangle
    }
    if (unrotY < unrotX && unrotY > (-unrotX + edge)) {
      return _sideColors[1]; // right triangle
    }
    if (unrotY >= unrotX && unrotY >= (-unrotX + edge)) {
      return _sideColors[2]; // bottom triangle
    }
    return _sideColors[3]; // left triangle
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_hitPulseTimer > 0) {
      _hitPulseTimer = (_hitPulseTimer - dt).clamp(0, _hitPulseDuration);
    }

    if (_missShakeTimer > 0) {
      _missShakeTimer = (_missShakeTimer - dt).clamp(0, _missShakeDuration);
      _shakePhase += dt;
    }

    if (_isRotating) {
      _rotationProgress += dt / _rotationDuration;
      final t = Curves.easeOutCubic.transform(_rotationProgress.clamp(0, 1));
      _currentAngle = _startAngle + (_targetAngle - _startAngle) * t;
      if (_rotationProgress >= 1) {
        if (_rotationDirection < 0) {
          _sideColors = [
            _sideColors[1],
            _sideColors[2],
            _sideColors[3],
            _sideColors[0]
          ];
        } else if (_rotationDirection > 0) {
          _sideColors = [
            _sideColors[3],
            _sideColors[0],
            _sideColors[1],
            _sideColors[2]
          ];
        }

        _currentAngle = 0;
        _startAngle = 0;
        _targetAngle = 0;
        _rotationDirection = 0;
        _isRotating = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final edge = size.x;

    canvas.save();

    if (_missShakeTimer > 0) {
      final intensity = _missShakeTimer / _missShakeDuration;
      final jitterX = sin(_shakePhase * 90) * 9 * intensity;
      canvas.translate(jitterX, 0);
    }

    if (_hitPulseTimer > 0) {
      final t = 1 - (_hitPulseTimer / _hitPulseDuration);
      final scale = 1 + sin(t * pi) * 0.08;
      canvas.translate(edge / 2, edge / 2);
      canvas.scale(scale, scale);
      canvas.translate(-edge / 2, -edge / 2);
    }

    canvas.translate(edge / 2, edge / 2);
    canvas.rotate(_currentAngle);
    canvas.translate(-edge / 2, -edge / 2);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.26)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 6, edge - 8, edge - 8),
        Radius.circular(edge * 0.08),
      ),
      shadowPaint,
    );

    // Solid base so the box never appears hollow between diagonals.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, edge, edge),
        Radius.circular(edge * 0.08),
      ),
      Paint()..color = const Color(0xFF101726),
    );

    final center = Offset(edge / 2, edge / 2);
    final topLeft = const Offset(0, 0);
    final topRight = Offset(edge, 0);
    final bottomRight = Offset(edge, edge);
    final bottomLeft = Offset(0, edge);

    final topTri = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    final rightTri = Path()
      ..moveTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    final bottomTri = Path()
      ..moveTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    final leftTri = Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(topLeft.dx, topLeft.dy)
      ..lineTo(center.dx, center.dy)
      ..close();

    canvas.drawPath(topTri, Paint()..color = _sideColors[0]);
    canvas.drawPath(rightTri, Paint()..color = _sideColors[1]);
    canvas.drawPath(bottomTri, Paint()..color = _sideColors[2]);
    canvas.drawPath(leftTri, Paint()..color = _sideColors[3]);

    final sectionPaths = [topTri, rightTri, bottomTri, leftTri];
    final activePath = sectionPaths[_matchIndex];
    canvas.drawPath(
      activePath,
      Paint()..color = Colors.white.withOpacity(0.28),
    );

    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(topLeft, bottomRight, linePaint);
    canvas.drawLine(topRight, bottomLeft, linePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, edge, edge),
        Radius.circular(edge * 0.08),
      ),
      Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final arrowPaint = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.fill;
    final arrowPath = Path();
    const double tip = 16;
    const double wing = 8;
    switch (_matchIndex) {
      case 0:
        arrowPath
          ..moveTo(edge / 2, -tip + 10)
          ..lineTo(edge / 2 - wing, -tip)
          ..lineTo(edge / 2 + wing, -tip)
          ..close();
        break;
      case 1:
        arrowPath
          ..moveTo(edge + tip - 10, edge / 2)
          ..lineTo(edge + tip, edge / 2 - wing)
          ..lineTo(edge + tip, edge / 2 + wing)
          ..close();
        break;
      case 2:
        arrowPath
          ..moveTo(edge / 2, edge + tip - 10)
          ..lineTo(edge / 2 - wing, edge + tip)
          ..lineTo(edge / 2 + wing, edge + tip)
          ..close();
        break;
      default:
        arrowPath
          ..moveTo(-tip + 10, edge / 2)
          ..lineTo(-tip, edge / 2 - wing)
          ..lineTo(-tip, edge / 2 + wing)
          ..close();
    }
    canvas.drawPath(arrowPath, arrowPaint);

    canvas.restore();
  }

  Rect get rect => Rect.fromCenter(
        center: Offset(position.x, position.y),
        width: size.x,
        height: size.y,
      );
}
