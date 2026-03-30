part of 'pokemon_bloc.dart';

/// Base class for all Pokemon states
@immutable
sealed class PokemonState {
  const PokemonState();
}

class PkState extends Equatable {
  const PkState({
    this.isLoading = false,
  });
  final bool isLoading;
  PkState copyWith({
    bool? isLoading,
  }) {
    return PkState(
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isLoading];
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PokemonLoaded &&
        other.pokemons == pokemons &&
        other.hasMore == hasMore &&
        other.currentOffset == currentOffset &&
        other.isLoadingMore == isLoadingMore &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
    pokemons,
    hasMore,
    currentOffset,
    isLoadingMore,
    errorMessage,
  );
}

/// Error state
final class PokemonError extends PokemonState {
  const PokemonError({required this.message});

  final String message;
}
