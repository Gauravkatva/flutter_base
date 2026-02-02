part of 'pokemon_bloc.dart';

/// Base class for all Pokemon events
@immutable
sealed class PokemonEvent {
  const PokemonEvent();
}

/// Event to load the initial Pokemon list
final class LoadPokemonList extends PokemonEvent {
  const LoadPokemonList();
}

/// Event to load more Pokemon (pagination)
final class LoadMorePokemon extends PokemonEvent {
  const LoadMorePokemon();
}

/// Event to refresh the Pokemon list
final class RefreshPokemonList extends PokemonEvent {
  const RefreshPokemonList();
}
