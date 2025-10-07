import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/pokemon_model.dart';
import 'package:myapp/services/pokemon_service.dart';

// Battle Screen
class BattleScreen extends StatefulWidget {
  final PokemonService pokemonService;

  BattleScreen({super.key, PokemonService? pokemonService})
      : this.pokemonService = pokemonService ?? PokemonService();

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  late Future<List<Pokemon>> _pokemonFuture;
  Pokemon? playerPokemon;
  Pokemon? opponentPokemon;
  String battleMessage = '';

  late AnimationController _playerShakeController;
  late Animation<double> _playerShakeAnimation;
  late AnimationController _opponentShakeController;
  late Animation<double> _opponentShakeAnimation;

  @override
  void initState() {
    super.initState();
    _pokemonFuture = _startBattle();

    _playerShakeController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _playerShakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_playerShakeController);

    _opponentShakeController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _opponentShakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_opponentShakeController);
  }

  Future<List<Pokemon>> _startBattle() async {
    final pokemon1 = await widget.pokemonService.getRandomPokemon();
    final pokemon2 = await widget.pokemonService.getRandomPokemon();

    playerPokemon = pokemon1;
    opponentPokemon = pokemon2;

    setState(() {
      battleMessage = 'A wild ${opponentPokemon!.name} appeared!';
    });

    return [pokemon1, pokemon2];
  }

  void _playerAttack(Move move) {
    if (playerPokemon == null || opponentPokemon == null) return;

    setState(() {
      final damage = (move.power * (Random().nextDouble() + 0.5)).round();
      opponentPokemon!.currentHealth -= damage;
      battleMessage = '${playerPokemon!.name} used ${move.name}!';
      _opponentShakeController.forward(from: 0);

      if (opponentPokemon!.currentHealth <= 0) {
        opponentPokemon!.currentHealth = 0;
        battleMessage += '\n${opponentPokemon!.name} fainted!';
        _showEndDialog(true);
      } else {
        Future.delayed(const Duration(seconds: 1), _opponentAttack);
      }
    });
  }

  void _opponentAttack() {
    if (playerPokemon == null || opponentPokemon == null) return;

    setState(() {
      final move = opponentPokemon!
          .moves[Random().nextInt(opponentPokemon!.moves.length)];
      final damage = (move.power * (Random().nextDouble() + 0.5)).round();
      playerPokemon!.currentHealth -= damage;
      battleMessage = '${opponentPokemon!.name} used ${move.name}!';
      _playerShakeController.forward(from: 0);

      if (playerPokemon!.currentHealth <= 0) {
        playerPokemon!.currentHealth = 0;
        battleMessage += '\n${playerPokemon!.name} fainted!';
        _showEndDialog(false);
      } else {
        // Prevents opponent from attacking if player has already won
        if (opponentPokemon!.currentHealth > 0) {
          Future.delayed(const Duration(seconds: 1));
        }
      }
    });
  }

  void _showEndDialog(bool playerWon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(playerWon ? 'You Won!' : 'You Lost!'),
        content: Text(playerWon
            ? 'You defeated the wild ${opponentPokemon!.name}!'
            : 'Your ${playerPokemon!.name} fainted!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _pokemonFuture = _startBattle();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Pokémon Battle', style: GoogleFonts.pressStart2p()),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.length < 2) {
            return const Center(child: Text('Failed to load Pokémon.'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Stack(
                    children: [
                      _buildPokemonInfo(
                          _opponentShakeAnimation, opponentPokemon!, true),
                      _buildPokemonInfo(
                          _playerShakeAnimation, playerPokemon!, false),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Text(battleMessage,
                      style: GoogleFonts.lato(fontSize: 18)),
                ),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                  ),
                  itemCount: playerPokemon!.moves.length,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // to prevent scrolling within the GridView
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final move = playerPokemon!.moves[index];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () => _playerAttack(move),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(move.name,
                            style: GoogleFonts.lato(fontSize: 16)),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPokemonInfo(
      Animation<double> shakeAnimation, Pokemon pokemon, bool isOpponent) {
    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        return Align(
          alignment: isOpponent ? Alignment.topLeft : Alignment.bottomRight,
          child: Transform.translate(
            offset: Offset(shakeAnimation.value, 0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(pokemon.imageUrl, height: 120),
                      Text(pokemon.name,
                          style: GoogleFonts.lato(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        child: LinearProgressIndicator(
                          value: pokemon.currentHealth / pokemon.maxHealth,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              pokemon.currentHealth / pokemon.maxHealth > 0.5
                                  ? Colors.green
                                  : pokemon.currentHealth / pokemon.maxHealth >
                                          0.2
                                      ? Colors.orange
                                      : Colors.red),
                        ),
                      ),
                      Text('${pokemon.currentHealth}/${pokemon.maxHealth}',
                          style: GoogleFonts.lato(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _playerShakeController.dispose();
    _opponentShakeController.dispose();
    super.dispose();
  }
}
