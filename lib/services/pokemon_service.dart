
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:myapp/screens/battle_screen.dart';

class PokemonService {
  final Random _random = Random();

  Future<Pokemon> getRandomPokemon() async {
    final int pokemonId = _random.nextInt(151) + 1;
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Move> moves = (data['moves'] as List)
          .map((moveData) => Move(name: moveData['move']['name'], power: 20)) // Simplified power
          .toList();

      return Pokemon(
        name: data['name'],
        imageUrl: data['sprites']['front_default'],
        maxHealth: 100,
        moves: (moves..shuffle()).take(4).toList(),
      );
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }
}
