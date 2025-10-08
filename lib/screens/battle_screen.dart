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
      : pokemonService = pokemonService ?? PokemonService();

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

  late AnimationController _playerAttackController;
  late Animation<Offset> _playerAttackAnimation;
  late AnimationController _opponentAttackController;
  late Animation<Offset> _opponentAttackAnimation;

  late AnimationController _playerFaintController;
  late Animation<double> _playerFaintAnimation;
  late AnimationController _opponentFaintController;
  late Animation<double> _opponentFaintAnimation;

  double? _playerPreviousHealth;
  double? _opponentPreviousHealth;

  final List<String> _battleLog = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

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

    _playerAttackController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _playerAttackAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.2, 0))
            .animate(CurvedAnimation(
      parent: _playerAttackController,
      curve: Curves.easeInOut,
    ));

    _opponentAttackController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _opponentAttackAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-0.2, 0))
            .animate(CurvedAnimation(
      parent: _opponentAttackController,
      curve: Curves.easeInOut,
    ));

    _playerFaintController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _playerFaintAnimation =
        CurvedAnimation(parent: _playerFaintController, curve: Curves.easeIn);

    _opponentFaintController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _opponentFaintAnimation =
        CurvedAnimation(parent: _opponentFaintController, curve: Curves.easeIn);
  }

  Future<List<Pokemon>> _startBattle() async {
    final pokemon1 = await widget.pokemonService.getRandomPokemon();
    final pokemon2 = await widget.pokemonService.getRandomPokemon();

    playerPokemon = pokemon1;
    opponentPokemon = pokemon2;

    _playerPreviousHealth = playerPokemon!.maxHealth.toDouble();
    _opponentPreviousHealth = opponentPokemon!.maxHealth.toDouble();

    _playerFaintController.reset();
    _opponentFaintController.reset();

    setState(() {
      _battleLog.clear();
      _addBattleLog('A wild ${opponentPokemon!.name} appeared!');
    });

    return [pokemon1, pokemon2];
  }

  void _addBattleLog(String message) {
    setState(() {
      battleMessage = message;
    });
    _battleLog.add(message);
    if (_listKey.currentState != null) {
      _listKey.currentState!
          .insertItem(0, duration: const Duration(milliseconds: 300));
    }
  }

  void _playerAttack(Move move) {
    if (playerPokemon == null || opponentPokemon == null) return;

    _playerAttackController.forward().then((_) {
      _playerAttackController.reverse();
    });

    setState(() {
      _opponentPreviousHealth = opponentPokemon!.currentHealth.toDouble();
      final damage = (move.power * (Random().nextDouble() + 0.5)).round();
      opponentPokemon!.currentHealth -= damage;
      _addBattleLog('${playerPokemon!.name} used ${move.name}!');
      _opponentShakeController.forward(from: 0);

      if (opponentPokemon!.currentHealth <= 0) {
        opponentPokemon!.currentHealth = 0;
        _opponentFaintController.forward();
        _addBattleLog('${opponentPokemon!.name} fainted!');
        Future.delayed(const Duration(seconds: 2), () => _showEndDialog(true));
      } else {
        Future.delayed(const Duration(seconds: 1), _opponentAttack);
      }
    });
  }

  void _opponentAttack() {
    if (playerPokemon == null ||
        opponentPokemon == null ||
        opponentPokemon!.currentHealth <= 0) {
      return;
    }

    _opponentAttackController.forward().then((_) {
      _opponentAttackController.reverse();
    });

    setState(() {
      _playerPreviousHealth = playerPokemon!.currentHealth.toDouble();
      final move = opponentPokemon!
          .moves[Random().nextInt(opponentPokemon!.moves.length)];
      final damage = (move.power * (Random().nextDouble() + 0.5)).round();
      playerPokemon!.currentHealth -= damage;
      _addBattleLog('${opponentPokemon!.name} used ${move.name}!');
      _playerShakeController.forward(from: 0);

      if (playerPokemon!.currentHealth <= 0) {
        playerPokemon!.currentHealth = 0;
        _playerFaintController.forward();
        _addBattleLog('${playerPokemon!.name} fainted!');
        Future.delayed(const Duration(seconds: 2), () => _showEndDialog(false));
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
                        key: ValueKey<String>(battleMessage),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pressStart2p(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                if (playerPokemon != null && playerPokemon!.currentHealth > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: _buildAttackButton(playerPokemon!.moves[0])),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildAttackButton(playerPokemon!.moves[1],
                                isSpecial: true)),
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
                ? Colors.purple.withValues(alpha: 0.5)
                : Colors.red.withValues(alpha: 0.5),
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
                  isSpecial
                      ? '${move.name.toUpperCase()} - ATK: ${move.power}'
                      : 'ATK: ${move.power}',
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
    final shakeAnimation =
        isOpponent ? _opponentShakeController : _playerShakeAnimation;
    final attackAnimation =
        isOpponent ? _opponentAttackAnimation : _playerAttackAnimation;
    final faintAnimation =
        isOpponent ? _opponentFaintAnimation : _playerFaintAnimation;
    final previousHealth =
        isOpponent ? _opponentPreviousHealth : _playerPreviousHealth;

    return FadeTransition(
      opacity: faintAnimation.drive(Tween<double>(begin: 1.0, end: 0.0)),
      child: SlideTransition(
        position: faintAnimation.drive(
            Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1.5))),
        child: AnimatedBuilder(
          animation: shakeAnimation,
          builder: (context, child) {
            return Align(
              alignment: isOpponent ? Alignment.topLeft : Alignment.bottomRight,
              child: SlideTransition(
                position: attackAnimation,
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
                            Image.network(pokemon.imageUrl,
                                height: 120, fit: BoxFit.cover),
                            Text(pokemon.name,
                                style: GoogleFonts.lato(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 150,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                    begin: previousHealth,
                                    end: pokemon.currentHealth.toDouble()),
                                duration: const Duration(milliseconds: 400),
                                builder: (context, animatedHp, child) {
                                  return LinearProgressIndicator(
                                    value: animatedHp / pokemon.maxHealth,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        animatedHp / pokemon.maxHealth > 0.5
                                            ? Colors.green
                                            : animatedHp / pokemon.maxHealth >
                                                    0.2
                                                ? Colors.orange
                                                : Colors.red),
                                  );
                                },
                              ),
                            ),
                            Text(
                                '${pokemon.currentHealth}/${pokemon.maxHealth}',
                                style: GoogleFonts.lato(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playerShakeController.dispose();
    _opponentShakeController.dispose();
    _playerAttackController.dispose();
    _opponentAttackController.dispose();
    _playerFaintController.dispose();
    _opponentFaintController.dispose();
    super.dispose();
  }
}
