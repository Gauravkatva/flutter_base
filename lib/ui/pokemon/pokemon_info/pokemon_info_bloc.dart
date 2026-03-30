import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/data/model/pokemon_information_model.dart';
import 'package:my_appp/utils/dio_client.dart';

part 'pokemon_info_event.dart';
part 'pokemon_info_state.dart';

class PokemonInfoBloc extends Bloc<PokemonInfoEvent, PokemonInfoState> {
  PokemonInfoBloc({required DioClient dio})
    : _dio = dio,
      super(PokemonInfoInitial()) {
    on<LoadPokemonInfo>(_loadPokemonInfo);
  }
  final DioClient _dio;

  FutureOr<void> _loadPokemonInfo(
    LoadPokemonInfo event,
    Emitter<PokemonInfoState> emit,
  ) async {
    emit(PokemonInfoLoading());
    final response = await _dio.get<Map<String, dynamic>>(event.url);
    if (response.statusCode == 200) {
      final information = PokemonInformation.fromJson(response.data!);
      emit(PokemonInfoLoaded(information: information));
    } else {
      emit(
        const PokemonInfoError(message: 'Failed to load pokemon information'),
      );
    }
  }
}
