import 'package:animal_mayhem/game/animal_mayhem_game.dart';
import 'package:animal_mayhem/game/components/animals/buffalo_component.dart';
import 'package:animal_mayhem/game/components/animals/cat_component.dart';
import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/components/animals/frog_component.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AnimalMayhemGame starts with the development background', () {
    final AnimalMayhemGame game = AnimalMayhemGame();

    expect(game.backgroundColor(), AnimalMayhemGame.developmentBackground);
  });

  testWidgets('Flame game loads the world and dog', (
    WidgetTester tester,
  ) async {
    final AnimalMayhemGame game = AnimalMayhemGame();
    await tester.pumpWidget(GameWidget(game: game));
    await tester.pump();
    await game.loaded;

    expect(game.isLoaded, isTrue);
    expect(game.world.dog, isA<DogComponent>());
    expect(game.world.duck, isA<DuckComponent>());
    expect(game.world.frog, isA<FrogComponent>());
    expect(game.world.cat, isA<CatComponent>());
    expect(game.world.buffalo, isA<BuffaloComponent>());
  });
}
