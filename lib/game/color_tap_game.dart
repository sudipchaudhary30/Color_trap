import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'ball.dart';
import 'platform.dart';
import 'particle_effect.dart';
import '../utils/constants.dart';

enum GameState { waiting, playing, dead }

class ColorTapGame extends FlameGame with TapCallbacks {
  // Callbacks to Flutter UI
  final VoidCallback onDeath;
  final Function(int) onScoreChanged;
  final VoidCallback? onFirstStart;

  GameState _state = GameState.waiting;
  late Ball _ball;
  late ColorPlatform _platform;
  final Random _random = Random();

  int _score = 0;
  Color _currentBallColor = AppColors.gameColors[0];
  double _platformY = 0;
  double _bounceCooldownTimer = 0;

  ColorTapGame({
    required this.onDeath,
    required this.onScoreChanged,
    this.onFirstStart,
  });

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    _platformY = size.y * AppConstants.platformY;
    _spawnBall();
    _spawnPlatform();
  }

  void _spawnBall() {
    _currentBallColor = _randomColor();
    _ball = Ball(
      position: Vector2(size.x / 2, size.y * AppConstants.ballStartY),
      color: _currentBallColor,
    );
    add(_ball);
  }

  void _spawnPlatform() {
    _platform = ColorPlatform(
      position: Vector2(size.x / 2, _platformY),
      colors: AppColors.gameColors,
      ballColor: _currentBallColor,
      screenWidth: size.x,
    );
    add(_platform);
  }

  Color _randomColor() {
    return AppColors.gameColors[_random.nextInt(AppColors.gameColors.length)];
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_state == GameState.dead || _state == GameState.waiting) return;

    if (_bounceCooldownTimer > 0) {
      _bounceCooldownTimer =
          (_bounceCooldownTimer - dt).clamp(0, AppConstants.bounceCooldown);
    }

    // Ball out of bounds (fell off screen)
    if (_ball.position.y > size.y + 100) {
      _triggerDeath();
      return;
    }

    final boxRect = _platform.rect;
    final boxTop = boxRect.top;
    final boxBottom = boxRect.bottom;
    final ballBottom = _ball.position.y + AppConstants.ballRadius;
    final ballTop = _ball.position.y - AppConstants.ballRadius;
    final overlapsX =
        _ball.position.x >= boxRect.left - AppConstants.ballRadius &&
            _ball.position.x <= boxRect.right + AppConstants.ballRadius;
    final landingContact = overlapsX &&
        _ball.velocityY >= 0 &&
        ballBottom >= boxTop &&
        ballTop < boxTop;

    // Hard solid-top barrier: if the ball is over the box and moving down, it
    // cannot pass through to below.
    if (landingContact) {
      _ball.position.y = boxTop - AppConstants.ballRadius;
    }

    if (!landingContact) {
      _ball.isGrounded = false;

      // Strict fail-safe: once the ball has gone below the box, end the run.
      if (_ball.position.y - AppConstants.ballRadius > boxBottom) {
        _triggerDeath();
      }
      return;
    }

    // Process only on first contact frame (false -> true).
    if (!_ball.isGrounded) {
      _ball.isGrounded = true;
      final hitColor = _platform.topColor;

      if (hitColor != _ball.color) {
        _platform.triggerMissShake();
        _triggerDeath(delayCallback: true);
        return;
      }

      if (_bounceCooldownTimer <= 0) {
        _ball.velocityY = AppConstants.ballBounceVelocity;
        _bounceCooldownTimer = AppConstants.bounceCooldown;
      }

      _platform.triggerHitPulse();
      add(ParticleEffect(
        position: Vector2(_ball.position.x, _platform.position.y),
        color: _ball.color,
      ));

      _score++;
      onScoreChanged(_score);
      _platform.increaseDifficulty(_score);
      _changeBallColor();
      _platform.randomizeSides();
    }
  }

  void _changeBallColor() {
    Color newColor;
    do {
      newColor = _randomColor();
    } while (newColor == _currentBallColor);
    _currentBallColor = newColor;
    _ball.color = newColor;
    _platform.updateBallColor(newColor);
  }

  void _triggerDeath({bool delayCallback = false}) {
    if (_state == GameState.dead) return;
    _state = GameState.dead;
    _ball.isAlive = false;

    // Explosion particles
    add(ParticleEffect(
      position: _ball.position.clone(),
      color: Colors.white,
    ));
    add(ParticleEffect(
      position: _ball.position.clone(),
      color: _ball.color,
    ));

    if (delayCallback) {
      Future<void>.delayed(const Duration(milliseconds: 90), onDeath);
    } else {
      onDeath();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_state == GameState.waiting) {
      _state = GameState.playing;
      onFirstStart?.call();
    }

    if (_state != GameState.playing) return;

    if (event.canvasPosition.x < size.x / 2) {
      _platform.rotateLeft();
    } else {
      _platform.rotateRight();
    }
  }

  void reset() {
    remove(_ball);
    remove(_platform);

    // Reset state
    _score = 0;
    _state = GameState.waiting;
    _ball.isGrounded = false;
    _bounceCooldownTimer = 0;

    // Re-spawn
    _spawnBall();
    _spawnPlatform();
  }
}
