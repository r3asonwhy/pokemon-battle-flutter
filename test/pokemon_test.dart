import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/pokemon_model.dart';

void main() {
  group('Pokemon', () {
    test('Pokemon should be created with correct initial values', () {
      final pokemon = Pokemon(
        name: 'Pikachu',
        imageUrl: 'pikachu.png',
        maxHealth: 100,
        moves: [Move(name: 'Thunder Shock', power: 40)],
      );

      expect(pokemon.name, 'Pikachu');
      expect(pokemon.imageUrl, 'pikachu.png');
      expect(pokemon.maxHealth, 100);
      expect(pokemon.currentHealth, 100);
      expect(pokemon.moves.length, 1);
      expect(pokemon.moves[0].name, 'Thunder Shock');
    });

    test('Pokemon currentHealth should be updated correctly', () {
      final pokemon = Pokemon(
        name: 'Pikachu',
        imageUrl: 'pikachu.png',
        maxHealth: 100,
        moves: [Move(name: 'Thunder Shock', power: 40)],
      );

      pokemon.currentHealth -= 20;
      expect(pokemon.currentHealth, 80);
    });
  });

  group('Move', () {
    test('Move should be created with correct initial values', () {
      final move = Move(name: 'Thunder Shock', power: 40);

      expect(move.name, 'Thunder Shock');
      expect(move.power, 40);
    });
  });
}
