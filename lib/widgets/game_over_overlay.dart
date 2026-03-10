import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GameOverOverlay extends StatefulWidget {
  final int score;
  final int bestScore;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.onRestart,
    required this.onHome,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 60, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get isNewBest => widget.score >= widget.bestScore && widget.score > 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: Container(
              color: Colors.black.withOpacity(0.75),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Game Over text
                    const Text(
                      'GAME OVER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (isNewBest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🏆 NEW BEST!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Score card
                    Container(
                      width: 240,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          _scoreRow(
                              'SCORE', '${widget.score}', Colors.white, 28),
                          const SizedBox(height: 10),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 10),
                          _scoreRow('BEST', '${widget.bestScore}',
                              AppColors.buttonColor, 20),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Restart button
                    _buildButton(
                      label: 'PLAY AGAIN',
                      color: AppColors.buttonColor,
                      onTap: widget.onRestart,
                    ),

                    const SizedBox(height: 14),

                    // Home button
                    _buildButton(
                      label: 'HOME',
                      color: Colors.white24,
                      onTap: widget.onHome,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _scoreRow(String label, String value, Color valueColor, double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 13, letterSpacing: 2)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: size,
                fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildButton(
      {required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}
