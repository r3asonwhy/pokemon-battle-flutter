import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:myapp/models/pokemon_model.dart';

class PokemonService {
  final http.Client client;

  PokemonService({http.Client? client}) : client = client ?? http.Client();

  Future<Pokemon> getRandomPokemon() async {
    final response = await client.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/${Random().nextInt(898) + 1}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final moves = (data['moves'] as List)
          .map((moveData) => Move(name: moveData['move']['name'], power: 20))
          .toList();

      return Pokemon(
        name: data['name'],
        imageUrl: data['sprites']['front_default'],
        maxHealth: 100,
        moves: moves.isNotEmpty ? moves : [Move(name: 'struggle', power: 10)],
      );
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }
}
