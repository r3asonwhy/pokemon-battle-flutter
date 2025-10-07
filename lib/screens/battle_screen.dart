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

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _pokemonFuture = _startBattle();
              });
            },
            child: const Text('Retry'),
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorDialog(snapshot.error.toString());
          });
          return const Center(child: Text('An error occurred.'));
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
                    _buildPokemonInfo(opponentPokemon!, true),
                    _buildPokemonInfo(playerPokemon!, false),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      battleMessage,
                      key: ValueKey<String>(battleMessage), // Important for AnimatedSwitcher to detect change
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(child: _buildAttackButton(playerPokemon!.moves[0])),
                    const SizedBox(width: 16),
                    Expanded(child: _buildAttackButton(playerPokemon!.moves[1], isSpecial: true)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}


  Widget _buildAttackButton(Move move, {bool isSpecial = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isSpecial
              ? [Colors.purple.shade400, Colors.purple.shade700]
              : [Colors.red.shade400, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isSpecial
                ? Colors.purple.withOpacity(0.5)
                : Colors.red.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _playerAttack(move),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(isSpecial ? Icons.star : Icons.flash_on, color: Colors.white),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSpecial ? 'Special Attack' : move.name.toUpperCase(),
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isSpecial ? '${move.name.toUpperCase()} - ATK: ${move.power}' : 'ATK: ${move.power}',
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonInfo(Pokemon pokemon, bool isOpponent) {
    final shakeAnimation = isOpponent ? _opponentShakeController : _playerShakeAnimation;
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
                       if (!isOpponent)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Your Pokémon',
                            style: GoogleFonts.pressStart2p(
                                fontSize: 10, color: Colors.blueAccent),
                          ),
                        ),
                      Image.network(pokemon.imageUrl, height: 120, fit: BoxFit.cover),
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
