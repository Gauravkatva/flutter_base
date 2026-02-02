/// API endpoints and base URLs
class ApiEndpoints {
  ApiEndpoints._();

  // Base URLs
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  // Pokemon endpoints
  static const String pokemon = '/pokemon';

  // Helper method to build URL with query parameters
  static String getPokemonList({int offset = 0, int limit = 20}) {
    return '$pokemon?offset=$offset&limit=$limit';
  }

  static String getPokemonDetail(String name) {
    return '$pokemon/$name';
  }
}
