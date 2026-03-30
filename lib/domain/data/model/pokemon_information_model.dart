import 'package:flutter/foundation.dart';

/// Represents a single ability of a Pokemon.
@immutable
class PokemonAbility {
  const PokemonAbility({
    required this.name,
    required this.url,
    required this.isHidden,
    required this.slot,
  });

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    final ability = json['ability'] as Map<String, dynamic>;
    return PokemonAbility(
      name: ability['name'] as String,
      url: ability['url'] as String,
      isHidden: json['is_hidden'] as bool,
      slot: json['slot'] as int,
    );
  }

  final String name;
  final String url;
  final bool isHidden;
  final int slot;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PokemonAbility &&
        other.name == name &&
        other.url == url &&
        other.isHidden == isHidden &&
        other.slot == slot;
  }

  @override
  int get hashCode => Object.hash(name, url, isHidden, slot);

  @override
  String toString() =>
      'PokemonAbility(name: $name, isHidden: $isHidden, slot: $slot)';
}

/// Pokemon information model containing abilities.
@immutable
class PokemonInformation {
  const PokemonInformation({
    required this.name,
    required this.abilities,
    required this.id,
  });

  factory PokemonInformation.fromJson(Map<String, dynamic> json) {
    final abilitiesList = (json['abilities'] as List<dynamic>)
        .map((e) => PokemonAbility.fromJson(e as Map<String, dynamic>))
        .toList();

    return PokemonInformation(
      name: json['name'] as String,
      abilities: abilitiesList,
      id: json['id'] as int,
    );
  }

  final String name;
  final List<PokemonAbility> abilities;
  final int id;

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PokemonInformation &&
        other.name == name &&
        listEquals(other.abilities, abilities) &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hashAll([name, ...abilities, id]);
  @override
  String toString() => 'PokemonInformation(name: $name, abilities: $abilities)';
}
