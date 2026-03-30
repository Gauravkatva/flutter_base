/// API endpoints and base URLs
class ApiEndpoints {
  ApiEndpoints._();

  // Base URLs
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  // Pokemon endpoints
  static const String pokemon = '/pokemon';

  static String getPokemonDetail(String name) {
    return '$pokemon/$name';
  }
}
