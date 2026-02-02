part of 'pokemon_bloc.dart';

/// Base class for all Pokemon states
@immutable
sealed class PokemonState {
  const PokemonState();
}

/// Initial state
final class PokemonInitial extends PokemonState {
  const PokemonInitial();
}

/// Loading state
final class PokemonLoading extends PokemonState {
  const PokemonLoading();
}

/// Loaded state with Pokemon list
final class PokemonLoaded extends PokemonState {
  const PokemonLoaded({
    required this.pokemons,
    required this.hasMore,
    required this.currentOffset,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<Pokemon> pokemons;
  final bool hasMore;
  final int currentOffset;
  final bool isLoadingMore;
  final String? errorMessage;

  PokemonLoaded copyWith({
    List<Pokemon>? pokemons,
    bool? hasMore,
    int? currentOffset,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return PokemonLoaded(
      pokemons: pokemons ?? this.pokemons,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

/// Error state
final class PokemonError extends PokemonState {
  const PokemonError({required this.message});

  final String message;
}
