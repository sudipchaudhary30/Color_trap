import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/color_tap_game.dart';
import '../utils/constants.dart';
import '../utils/score_manager.dart';
import '../widgets/score_hud.dart';
import '../widgets/game_over_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ColorTapGame _game;
  int _score = 0;
  bool _isDead = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _createGame();
  }

  void _createGame() {
    _game = ColorTapGame(
      onDeath: _onDeath,
      onScoreChanged: _onScoreChanged,
      onFirstStart: _onFirstStart,
    );
  }

  void _onFirstStart() {
    if (_hasStarted || !mounted) return;
    setState(() => _hasStarted = true);
  }

  void _onScoreChanged(int score) {
    setState(() => _score = score);
  }

  Future<void> _onDeath() async {
    await ScoreManager.incrementDeaths();
    await ScoreManager.updateBestScore(_score);

    if (mounted) {
      setState(() => _isDead = true);
    }
  }

  void _restart() {
    setState(() {
      _score = 0;
      _isDead = false;
      _hasStarted = false;
    });
    _game.reset();
  }

  void _goHome() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Flame game
          GameWidget(game: _game),

          // Score HUD
          if (!_isDead)
            ScoreHud(score: _score, bestScore: ScoreManager.bestScore),

          // Ball color indicator
          if (!_isDead) const BallColorIndicator(),

          // Game over overlay
          if (_isDead)
            GameOverOverlay(
              score: _score,
              bestScore: ScoreManager.bestScore,
              onRestart: _restart,
              onHome: _goHome,
            ),

          // Tap to start hint
          if (!_isDead && !_hasStarted) const TapToStartHint(),
        ],
      ),
    );
  }
}

class BallColorIndicator extends StatelessWidget {
  const BallColorIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Ball handles its own color visually
  }
}

class TapToStartHint extends StatefulWidget {
  const TapToStartHint({super.key});

  @override
  State<TapToStartHint> createState() => _TapToStartHintState();
}

class _TapToStartHintState extends State<TapToStartHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.11,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _anim,
        child: const Text(
          'TAP LEFT OR RIGHT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}
