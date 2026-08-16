import 'package:animal_mayhem/app/app.dart';
import 'package:animal_mayhem/core/constants/app_strings.dart';
import 'package:animal_mayhem/features/gameplay/game_screen.dart';
import 'package:animal_mayhem/features/home/home_screen.dart';
import 'package:animal_mayhem/game/animal_mayhem_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('application initializes on the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AnimalMayhemApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.homeTagline), findsOneWidget);
    expect(find.widgetWithText(FilledButton, AppStrings.play), findsOneWidget);
  });

  testWidgets('PLAY navigates to the game screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimalMayhemApp());

    await tester.tap(find.byKey(HomeScreen.playButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.byType(GameWidget<AnimalMayhemGame>), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text(AppStrings.gameScreenTitle),
      ),
      findsOneWidget,
    );
  });
}
