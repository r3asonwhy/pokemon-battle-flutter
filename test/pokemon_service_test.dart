import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/pokemon_model.dart';
import 'package:myapp/services/pokemon_service.dart';

import 'pokemon_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('PokemonService', () {
    late PokemonService pokemonService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      pokemonService = PokemonService(client: mockClient);
    });

    test('getRandomPokemon returns a Pokemon on successful API call', () async {
      final pokemonResponse = {
        'name': 'bulbasaur',
        'sprites': {
          'front_default':
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
          'other': {
            'official-artwork': {
              'front_default':
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png'
            }
          }
        },
        'stats': [
          {
            'base_stat': 45,
            'stat': {'name': 'hp'}
          },
          {
            'base_stat': 49,
            'stat': {'name': 'attack'}
          }
        ],
        'moves': [
          {
            'move': {
              'name': 'razor-wind',
              'url': 'https://pokeapi.co/api/v2/move/13/'
            }
          }
        ]
      };

      final moveResponse = {
        'name': 'razor-wind',
        'power': 80,
      };

      when(mockClient.get(any)).thenAnswer((realInvocation) async {
        if (realInvocation.positionalArguments[0].toString().contains('move')) {
          return http.Response(json.encode(moveResponse), 200);
        }
        return http.Response(json.encode(pokemonResponse), 200);
      });

      final pokemon = await pokemonService.getRandomPokemon();

      expect(pokemon, isA<Pokemon>());
      expect(pokemon.name, 'bulbasaur');
      expect(pokemon.imageUrl,
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png');
      expect(pokemon.maxHealth, 45);
      expect(pokemon.moves.length, 2);
      expect(pokemon.moves[0].name, 'tackle');
      expect(pokemon.moves[0].power, 49);
      expect(pokemon.moves[1].name, 'razor-wind');
      expect(pokemon.moves[1].power, 80);
    });

    test('getRandomPokemon throws an exception on failed API call', () {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(pokemonService.getRandomPokemon(), throwsException);
    });
  });
}
