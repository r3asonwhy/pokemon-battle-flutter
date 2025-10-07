import 'package:flutter/material.dart';
import 'package:myapp/screens/battle_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Battle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BattleScreen(),
    );
  }
}
