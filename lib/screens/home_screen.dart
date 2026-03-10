import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/score_manager.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _introController;
  late final Animation<double> _buttonScale;
  late final Animation<double> _introOpacity;
  late final Animation<Offset> _introSlide;

  @override
  void initState() {
    super.initState();
    _loadBestScore();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _buttonScale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _introOpacity = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    );

    _introSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _loadBestScore() async {
    await ScoreManager.load();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          _AnimatedBackdrop(controller: _floatController),
          SafeArea(
            child: FadeTransition(
              opacity: _introOpacity,
              child: SlideTransition(
                position: _introSlide,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: topPadding + 12),
                      const Spacer(flex: 2),
                      _AnimatedTitle(controller: _floatController),
                      const SizedBox(height: 32),
                      _BouncingColorDots(controller: _floatController),
                      const Spacer(flex: 2),
                      Text(
                        'BEST: ${ScoreManager.bestScore}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 34),
                      ScaleTransition(
                        scale: _buttonScale,
                        child: _PlayButton(
                          floatController: _floatController,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GameScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Tap left/right to rotate box • Match top color',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackdrop extends StatelessWidget {
  const _AnimatedBackdrop({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value * 2 * math.pi;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF121A35),
                Color(0xFF111827),
                Color(0xFF0D1020),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 80 + math.sin(t) * 24,
                left: -70 + math.cos(t * 0.6) * 18,
                child: _GlowBlob(
                  size: 220,
                  color: AppColors.gameColors[0].withOpacity(0.16),
                ),
              ),
              Positioned(
                top: 260 + math.sin(t * 1.1) * 18,
                right: -60 + math.cos(t * 0.8) * 22,
                child: _GlowBlob(
                  size: 210,
                  color: AppColors.gameColors[2].withOpacity(0.14),
                ),
              ),
              Positioned(
                bottom: -90 + math.cos(t * 0.9) * 16,
                left: 40 + math.sin(t * 0.75) * 20,
                child: _GlowBlob(
                  size: 260,
                  color: AppColors.gameColors[1].withOpacity(0.12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 50, spreadRadius: 18),
        ],
      ),
    );
  }
}

class _AnimatedTitle extends StatelessWidget {
  const _AnimatedTitle({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final wobble = math.sin(controller.value * 2 * math.pi) * 4;

        return Transform.translate(
          offset: Offset(0, wobble),
          child: Column(
            children: [
              const Text(
                'COLOR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 7,
                ),
              ),
              ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFF2ED573)],
                  ).createShader(rect);
                },
                child: const Text(
                  'TAP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 9,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BouncingColorDots extends StatelessWidget {
  const _BouncingColorDots({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(AppColors.gameColors.length, (index) {
            final phase = controller.value * 2 * math.pi + index * 0.8;
            final y = math.sin(phase) * 8;
            final scale = 0.9 + (math.sin(phase + 0.5) + 1) * 0.15;
            final color = AppColors.gameColors[index];

            return Transform.translate(
              offset: Offset(0, y),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.65),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.floatController, required this.onTap});

  final Animation<double> floatController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (context, _) {
        final sweep = (floatController.value * 300) - 140;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 200,
            height: 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const LinearGradient(
                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withOpacity(0.55),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: sweep,
                  top: 0,
                  bottom: 0,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: Container(
                      width: 40,
                      color: Colors.white.withOpacity(0.22),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'PLAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
