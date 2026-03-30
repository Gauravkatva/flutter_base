import 'package:flutter/material.dart';
import 'package:my_appp/domain/data/model/pokemon_model.dart';
import 'package:my_appp/ui/pokemon/ui/pokemon_information_page.dart';

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
          radius: 40,
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
        onTap: () => Navigator.of(
          context,
        ).push(PokemonInformationPage.route(pokemon.url)),
      ),
    );
  }
}
