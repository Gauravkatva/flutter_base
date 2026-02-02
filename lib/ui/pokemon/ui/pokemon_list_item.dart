import 'package:flutter/material.dart';
import 'package:my_appp/domain/data/model/pokemon_model.dart';

/// Widget to display a single Pokemon in the list
class PokemonListItem extends StatelessWidget {
  const PokemonListItem({
    required this.pokemon,
    super.key,
  });

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: NetworkImage(pokemon.imageUrl),
        ),
        title: Text(
          pokemon.name.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('ID: ${pokemon.id}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to Pokemon detail page (placeholder)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on ${pokemon.name}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
