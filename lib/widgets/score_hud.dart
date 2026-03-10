import 'package:flutter/material.dart';

class ScoreHud extends StatelessWidget {
  final int score;
  final int bestScore;

  const ScoreHud({super.key, required this.score, required this.bestScore});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Current score
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              height: 1,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          if (bestScore > 0)
            Text(
              'BEST: $bestScore',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
        ],
      ),
    );
  }
}
