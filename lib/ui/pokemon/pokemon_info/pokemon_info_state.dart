part of 'pokemon_info_bloc.dart';

sealed class PokemonInfoState extends Equatable {
  const PokemonInfoState();

  @override
  List<Object> get props => [];
}

final class PokemonInfoInitial extends PokemonInfoState {}

final class PokemonInfoLoading extends PokemonInfoState {}

final class PokemonInfoLoaded extends PokemonInfoState {
  const PokemonInfoLoaded({required this.information});

  final PokemonInformation information;

  @override
  List<Object> get props => [information];
}

final class PokemonInfoError extends PokemonInfoState {
  const PokemonInfoError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}
