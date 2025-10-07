import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:myapp/models/pokemon_model.dart';

class PokemonService {
  final http.Client client;

  PokemonService({http.Client? client}) : this.client = client ?? http.Client();

  Future<Pokemon> getRandomPokemon() async {
    final response = await client
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${Random().nextInt(151) + 1}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final moves = (data['moves'] as List);

      Move specialMove;
      if (moves.isNotEmpty) {
        final moveData = moves[Random().nextInt(moves.length)];
        final moveResponse = await client.get(Uri.parse(moveData['move']['url']));
        if (moveResponse.statusCode == 200) {
          final moveDetails = json.decode(moveResponse.body);
          specialMove = Move(name: moveDetails['name'], power: moveDetails['power'] ?? 50); // Use a default power if null
        } else {
          specialMove = Move(name: 'hyper-beam', power: 150); // Fallback special move
        }
      } else {
        specialMove = Move(name: 'hyper-beam', power: 150); // Fallback special move
      }

      return Pokemon(
        name: data['name'],
        imageUrl: data['sprites']['other']['official-artwork']['front_default'] ?? data['sprites']['front_default'],
        maxHealth: 100,
        moves: [Move(name: 'tackle', power: 40), specialMove],
      );
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }
}
