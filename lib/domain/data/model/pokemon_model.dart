import 'package:flutter/foundation.dart';

/// Pokemon entity - domain model
@immutable
class Pokemon {
  const Pokemon({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  /// Extract Pokemon ID from URL
  /// URL format: https://pokeapi.co/api/v2/pokemon/1/
  int get id {
    final segments = url.split('/');
    final filteredSegments = segments.where((s) => s.isNotEmpty).toList();
    return int.parse(filteredSegments[filteredSegments.length - 1]);
  }

  /// Get Pokemon image URL
  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pokemon && other.name == name && other.url == url;
  }

  @override
  int get hashCode => Object.hash(name, url);

  @override
  String toString() => 'Pokemon(name: $name, url: $url)';
}

/// Pokemon model - data transfer object with JSON serialization
class PokemonModel extends Pokemon {
  const PokemonModel({
    required super.name,
    required super.url,
  });

  /// Create from JSON
  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }
}

/// Pokemon list response from API
class PokemonListResponse {
  const PokemonListResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  /// Create from JSON
  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => PokemonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int count;
  final String? next;
  final String? previous;
  final List<Pokemon> results;

  /// Check if there are more pages
  bool get hasNext => next != null;

  /// Check if there is a previous page
  bool get hasPrevious => previous != null;
}
