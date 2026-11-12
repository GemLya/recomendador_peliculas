import 'dart:math';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';

/// Estado de ánimo del usuario, asociado a un género de TMDB.
/// Si [genreId] es null, se muestran las tendencias de la semana.
class Mood {
  final String label;
  final String emoji;
  final int? genreId;

  const Mood(this.label, this.emoji, this.genreId);
}

const List<Mood> moods = [
  Mood('Tendencias', '🔥', null),
  Mood('Feliz', '😄', 35), // Comedia
  Mood('Triste', '😢', 18), // Drama
  Mood('Emocionado', '🤩', 28), // Acción
  Mood('Romántico', '😍', 10749), // Romance
  Mood('Con ganas de miedo', '😱', 27), // Terror
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TmdbService _service = TmdbService();

  late Mood _selectedMood;
  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _selectedMood = moods.first;
    _moviesFuture = _loadMovies();
  }

  Future<List<Movie>> _loadMovies() {
    final genreId = _selectedMood.genreId;
    return genreId == null
        ? _service.getTrending()
        : _service.getByGenre(genreId);
  }

  void _selectMood(Mood mood) {
    setState(() {
      _selectedMood = mood;
      _moviesFuture = _loadMovies();
    });
  }

  void _retry() {
    setState(() {
      _moviesFuture = _loadMovies();
    });
  }

  /// Elige una película al azar de la lista actual y la muestra en un diálogo.
  Future<void> _surpriseMe() async {
    try {
      final movies = await _moviesFuture;
      if (movies.isEmpty || !mounted) return;

      final movie = movies[Random().nextInt(movies.length)];

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🎬 Tu película de hoy'),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          content: SizedBox(
            width: double.maxFinite,
            child: MovieCard(movie: movie),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('¡Perfecto!'),
            ),
          ],
        ),
      );
    } catch (_) {
      // El error ya se muestra en el FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍿 Película del Fin de Semana'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMoodSelector(),
          const Divider(height: 1),
          Expanded(child: _buildMovieList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _surpriseMe,
        icon: const Icon(Icons.casino),
        label: const Text('Sorpréndeme'),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo te sientes hoy?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: moods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final mood = moods[index];
                return ChoiceChip(
                  label: Text('${mood.emoji} ${mood.label}'),
                  selected: mood == _selectedMood,
                  onSelected: (_) => _selectMood(mood),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieList() {
    return FutureBuilder<List<Movie>>(
      future: _moviesFuture,
      builder: (context, snapshot) {
        // 1. Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Error
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'No se pudieron cargar las películas.\n'
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        // 3. Sin resultados
        final movies = snapshot.data ?? [];
        if (movies.isEmpty) {
          return const Center(child: Text('No se encontraron películas.'));
        }

        // 4. Lista de películas
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: movies.length,
          itemBuilder: (context, index) => MovieCard(movie: movies[index]),
        );
      },
    );
  }
}
