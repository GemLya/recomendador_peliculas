import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

/// Servicio que se comunica con The Movie Database (TMDB).
class TmdbService {
  static const String _apiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: 'eca6f6c71a5c1b31265b1ec8a6bc4471',
  );

  static const String _host = 'api.themoviedb.org';

  final http.Client _client;

  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  /// Películas en tendencia de la semana.
  Future<List<Movie>> getTrending() {
    return _fetchMovies('/3/trending/movie/week');
  }

  /// Películas populares de un género (según el estado de ánimo).
  Future<List<Movie>> getByGenre(int genreId) {
    return _fetchMovies('/3/discover/movie', {
      'with_genres': genreId.toString(),
      'sort_by': 'popularity.desc',
      'vote_count.gte': '200', // evita películas casi desconocidas
    });
  }

  Future<List<Movie>> _fetchMovies(
    String path, [
    Map<String, String> extraParams = const {},
  ]) async {
    if (_apiKey == 'TU_API_KEY_AQUI') {
      throw Exception(
        'Falta la API key de TMDB. Configúrala en tmdb_service.dart '
        'o usa --dart-define=TMDB_API_KEY=tu_api_key',
      );
    }

    final uri = Uri.https(_host, path, {
      'api_key': _apiKey,
      'language': 'es-MX',
      ...extraParams,
    });

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Error del servidor (código ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    return results
        .map((json) => Movie.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}