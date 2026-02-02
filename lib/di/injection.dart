import 'package:get_it/get_it.dart';
import 'package:my_appp/domain/data/pokemon/pokemon_api.dart';
import 'package:my_appp/ui/pokemon/bloc/pokemon_bloc.dart';
import 'package:my_appp/utils/dio_client.dart';

/// Service locator instance
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Core - HTTP client
  sl
    ..registerLazySingleton<DioClient>(DioClient.new)

    // Pokemon Feature
    // API
    ..registerLazySingleton<PokemonApi>(() => PokemonApi(sl()))

    // BLoC - Factory (new instance for each page)
    ..registerFactory(() => PokemonBloc(pokemonApi: sl()));
}
