import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:my_appp/domain/data/model/pokemon_model.dart';
import 'package:my_appp/domain/data/pokemon/pokemon_api.dart';

part 'pokemon_event.dart';
part 'pokemon_state.dart';

/// BLoC for managing Pokemon list state
class PokemonBloc extends Bloc<PokemonEvent, PokemonState> {
  PokemonBloc({
    required PokemonApi pokemonApi,
  })  : _pokemonApi = pokemonApi,
        super(const PokemonInitial()) {
    on<LoadPokemonList>(_onLoadPokemonList);
    on<LoadMorePokemon>(_onLoadMorePokemon);
    on<RefreshPokemonList>(_onRefreshPokemonList);
  }

  final PokemonApi _pokemonApi;

  static const int _pageSize = 20;

  Future<void> _onLoadPokemonList(
    LoadPokemonList event,
    Emitter<PokemonState> emit,
  ) async {
    emit(const PokemonLoading());

    final response = await _pokemonApi.getPokemonList();
    if (response.isSuccess && response.data != null) {
      emit(
        PokemonLoaded(
          pokemons: response.data!.results,
          hasMore: response.data!.hasNext,
          currentOffset: _pageSize,
        ),
      );
    } else {
      emit(
        PokemonLoaded(
          pokemons: const [],
          hasMore: false,
          currentOffset: 0,
          errorMessage: response.error?.message ?? 'Unknown error',
        ),
      );
    }
  }

  Future<void> _onLoadMorePokemon(
    LoadMorePokemon event,
    Emitter<PokemonState> emit,
  ) async {
    if (state is! PokemonLoaded) return;

    final currentState = state as PokemonLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final response = await _pokemonApi.getPokemonList(
      offset: currentState.currentOffset,
    );

    if (response.isSuccess && response.data != null) {
      emit(
        PokemonLoaded(
          pokemons: [...currentState.pokemons, ...response.data!.results],
          hasMore: response.data!.hasNext,
          currentOffset: currentState.currentOffset + _pageSize,
        ),
      );
    } else {
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          errorMessage: response.error?.message ?? 'Unknown error',
        ),
      );
    }
  }

  Future<void> _onRefreshPokemonList(
    RefreshPokemonList event,
    Emitter<PokemonState> emit,
  ) async {
    final response = await _pokemonApi.getPokemonList();
    if (response.isSuccess && response.data != null) {
      emit(
        PokemonLoaded(
          pokemons: response.data!.results,
          hasMore: response.data!.hasNext,
          currentOffset: _pageSize,
        ),
      );
    } else {
      final currentState = state;
      if (currentState is PokemonLoaded) {
        emit(
          currentState.copyWith(
            errorMessage: response.error?.message ?? 'Unknown error',
          ),
        );
      } else {
        emit(
          PokemonLoaded(
            pokemons: const [],
            hasMore: false,
            currentOffset: 0,
            errorMessage: response.error?.message ?? 'Unknown error',
          ),
        );
      }
    }
  }
}
