import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:my_appp/domain/data/contacts/contacts_api.dart';
import 'package:my_appp/domain/data/local/local_storage.dart';
import 'package:my_appp/domain/data/local/shared_prefs_storage.dart';
import 'package:my_appp/domain/data/local/sqflite_storage.dart';
import 'package:my_appp/domain/data/luxury/luxury_api.dart';
import 'package:my_appp/domain/data/pokemon/pokemon_api.dart';
import 'package:my_appp/utils/dio_client.dart';

/// Service locator instance
final GetIt getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  final random = Random();
  // Core - HTTP client
  getIt
    ..registerLazySingleton<DioClient>(DioClient.new)
    // Local Storage
    ..registerLazySingleton<LocalStorage>(
      SqfliteStorage.new,
      instanceName: 'sqflite',
    )
    ..registerLazySingleton<LocalStorage>(
      SharedPrefsStorage.new,
      instanceName: 'sharedPrefs',
    )
    // Pokemon Feature - API
    ..registerLazySingleton<PokemonApi>(
      () => PokemonApi(getIt.get<DioClient>()),
    )
    ..registerLazySingleton<ContactsApi>(
      () => ContactsApi(dioClient: getIt.get<DioClient>()),
    )
    ..registerLazySingleton<LuxuryApi>(
      () => LuxuryApi(random),
    );

  // Initialize storage backends
  await getIt.get<LocalStorage>(instanceName: 'sqflite').init();
  await getIt.get<LocalStorage>(instanceName: 'sharedPrefs').init();
}
