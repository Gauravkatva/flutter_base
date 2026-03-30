import 'package:my_appp/di/injection.dart';
import 'package:my_appp/domain/data/local/sqflite_storage.dart';
import 'package:my_appp/utils/dio_client.dart';

import 'mock_classes.mocks.dart';

Future<void> initializeMockDependencies() async {
  getIt
    ..registerLazySingleton<DioClient>(() => DioClient(dio: MockDio()))
    ..registerLazySingleton<SqfliteStorage>(MockSqfliteStorage.new);
}
