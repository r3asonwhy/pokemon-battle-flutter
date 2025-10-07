import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/pokemon_model.dart';
import 'package:myapp/screens/battle_screen.dart';
import 'package:myapp/main.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/services/pokemon_service.dart';

import 'pokemon_service_test.mocks.dart';

void main() {
  testWidgets('BattleScreen shows loading indicator and then battle UI', (WidgetTester tester) async {
    final mockPokemonService = MockPokemonService();

    when(mockPokemonService.getRandomPokemon()).thenAnswer((_) async => Pokemon(
      name: 'Pikachu',
      imageUrl: 'pikachu.png',
      maxHealth: 100,
      moves: [
        Move(name: 'tackle', power: 40),
        Move(name: 'thunder-shock', power: 60),
      ],
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: BattleScreen(pokemonService: mockPokemonService),
      ),
    );

    // Expect to find a loading indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the Future to complete.
    await tester.pumpAndSettle();

    // Expect to find the battle UI.
    expect(find.text('Pokémon Battle'), findsOneWidget);
    // Check for two buttons
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });
}
