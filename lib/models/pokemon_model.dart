class Move {
  final String name;
  final int power;

  Move({required this.name, required this.power});
}

class Pokemon {
  final String name;
  final String imageUrl;
  final int maxHealth;
  int currentHealth;
  final List<Move> moves;

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.maxHealth,
    required this.moves,
  }) : currentHealth = maxHealth;
}
