import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/models/pokemon_model.dart';
import 'package:myapp/services/pokemon_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';

import 'pokemon_service_test.mocks.dart';

@GenerateMocks([http.Client, PokemonService])
void main() {
  group('PokemonService', () {
    test('getRandomPokemon should return a Pokemon on success', () async {
      final client = MockClient();
      final pokemonService = PokemonService(client: client);

      when(client.get(any)).thenAnswer((_) async => http.Response(
          json.encode({
            'name': 'pikachu',
            'sprites': {'front_default': 'pikachu.png'},
            'moves': [
              {
                'move': {'name': 'thunder-shock'}
              }
            ]
          }),
          200));

      final pokemon = await pokemonService.getRandomPokemon();

      expect(pokemon, isA<Pokemon>());
      expect(pokemon.name, 'pikachu');
      expect(pokemon.imageUrl, 'pikachu.png');
    });

    test('getRandomPokemon should throw an exception on failure', () async {
      final client = MockClient();
      final pokemonService = PokemonService(client: client);

      when(client.get(any))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(pokemonService.getRandomPokemon(), throwsException);
    });
  });
}
