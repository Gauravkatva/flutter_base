import 'package:dio/dio.dart' hide Response;
import 'package:my_appp/domain/constants/api_endpoints.dart';
import 'package:my_appp/domain/data/common/error_handler.dart';
import 'package:my_appp/domain/data/common/error_response.dart';
import 'package:my_appp/domain/data/common/response.dart';
import 'package:my_appp/domain/data/model/pokemon_model.dart';
import 'package:my_appp/utils/dio_client.dart';

/// Pokemon API - handles all API calls for Pokemon
class PokemonApi {
  const PokemonApi(this._dioClient);

  final DioClient _dioClient;

  /// Get list of pokemon with pagination
  Future<Response<PokemonListResponse>> getPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.pokemon}',
        queryParameters: {
          'offset': offset,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final pokemonList = PokemonListResponse.fromJson(response.data!);
        return Response.success(pokemonList);
      } else {
        return Response.error(
          ErrorResponse(
            message: 'Failed to load pokemon list',
            code: 'LOAD_FAILED',
            statusCode: response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      return Response.error(ErrorHandler.handleDioException(e));
    } on Exception catch (e) {
      return Response.error(ErrorHandler.handleException(e));
    }
  }
}
