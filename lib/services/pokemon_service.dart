import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:myapp/models/pokemon_model.dart';

class PokemonService {
  final http.Client client;

  PokemonService({http.Client? client}) : client = client ?? http.Client();

  Future<Pokemon> getRandomPokemon() async {
    final response = await client.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/${Random().nextInt(151) + 1}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final moves = (data['moves'] as List);
      final stats = (data['stats'] as List);
      final maxHealth = _getBaseStat(stats, 'hp', 100);
      final power = _getBaseStat(stats, 'attack', 40);

      Move specialMove;
      if (moves.isNotEmpty) {
        final moveData = moves[Random().nextInt(moves.length)];
        final moveResponse =
            await client.get(Uri.parse(moveData['move']['url']));
        if (moveResponse.statusCode == 200) {
          final moveDetails = json.decode(moveResponse.body);
          specialMove = Move(
              name: moveDetails['name'],
              power: moveDetails['power'] ?? 50); // Use a default power if null
        } else {
          specialMove =
              Move(name: 'hyper-beam', power: 150); // Fallback special move
        }
      } else {
        specialMove =
            Move(name: 'hyper-beam', power: 150); // Fallback special move
      }

      return Pokemon(
        name: data['name'],
        imageUrl: data['sprites']['other']['official-artwork']
                ['front_default'] ??
            data['sprites']['front_default'],
        maxHealth: maxHealth,
        moves: [Move(name: 'tackle', power: power), specialMove],
      );
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }

  int _getBaseStat(List<dynamic> stats, String statName, int defaultValue) {
    try {
      // Attempt to find the stat
      final statEntry = stats.firstWhere(
        (it) {
          // Safe access check: assuming 'it' is a Map or has similar access
          if (it is Map &&
              it.containsKey('stat') &&
              it['stat'] is Map &&
              it['stat'].containsKey('name')) {
            return it['stat']['name'] == statName;
          }
          // If it's a dynamic object (e.g., from JSON decoding),
          // the original access might work, but casting is safer.
          // If it's a strongly typed object, use `it.stat.name`.
          // Sticking to the dynamic map access pattern for refactoring raw JSON data.
          return it is Map &&
              it['stat'] != null &&
              (it['stat'] as Map)['name'] == statName;
        },
        // Provide a fallback entry if the stat isn't found
        // This fallback structure must match the expected structure
        orElse: () => null, // Use null as a sentinel if nothing is found
      );

      // Safely extract the `base_stat`
      if (statEntry != null &&
          statEntry is Map &&
          statEntry.containsKey('base_stat') &&
          statEntry['base_stat'] is int) {
        return statEntry['base_stat'] as int;
      }
    } catch (e) {
      // Log the error if finding the stat failed for unexpected reasons
      // print('Error finding stat $statName: $e');
    }

    return defaultValue;
  }
}
