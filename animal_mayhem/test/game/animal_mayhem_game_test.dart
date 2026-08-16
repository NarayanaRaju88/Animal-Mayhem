import 'package:animal_mayhem/game/animal_mayhem_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AnimalMayhemGame starts with the development background', () {
    final AnimalMayhemGame game = AnimalMayhemGame();

    expect(game.backgroundColor(), AnimalMayhemGame.developmentBackground);
  });
}
