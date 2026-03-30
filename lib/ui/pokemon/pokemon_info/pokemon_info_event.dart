part of 'pokemon_info_bloc.dart';

sealed class PokemonInfoEvent extends Equatable {
  const PokemonInfoEvent();

  @override
  List<Object> get props => [];
}

class LoadPokemonInfo extends PokemonInfoEvent {
  const LoadPokemonInfo({required this.url});
  final String url;
  @override
  List<Object> get props => [url];
}
