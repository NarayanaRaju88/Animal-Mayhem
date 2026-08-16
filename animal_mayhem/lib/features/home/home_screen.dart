import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../game/components/animals/animal_art.dart';

/// Home screen for Animal Mayhem.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Key playButtonKey = Key('home_play_button');

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF1A3328), Color(0xFF0E1C16)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double horizontalPadding = constraints.maxWidth >= 600
                  ? 48
                  : 24;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 96,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              for (final AnimalArtKind kind in <AnimalArtKind>[
                                AnimalArtKind.cat,
                                AnimalArtKind.buffalo,
                                AnimalArtKind.snake,
                                AnimalArtKind.monkey,
                              ])
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: CustomPaint(
                                    size: const Size(64, 88),
                                    painter: _HomeAnimalPainter(kind),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppStrings.appName,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF3E6C8),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Animal puzzle adventure',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFD4A017),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.homeTagline,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFFC5D6C8),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 48),
                        FilledButton(
                          key: playButtonKey,
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.game);
                          },
                          child: const Text(AppStrings.play),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeAnimalPainter extends CustomPainter {
  _HomeAnimalPainter(this.kind);

  final AnimalArtKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    AnimalArt.paint(canvas, size, kind: kind);
  }

  @override
  bool shouldRepaint(covariant _HomeAnimalPainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}
