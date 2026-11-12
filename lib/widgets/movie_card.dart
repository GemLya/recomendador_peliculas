import 'package:flutter/material.dart';

import '../models/movie.dart';

/// Tarjeta que muestra el póster, título, calificación y descripción.
class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Poster(url: movie.posterUrl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(movie.voteAverage.toStringAsFixed(1)),
                        if (movie.year.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Text(
                            movie.year,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        movie.overview.isEmpty
                            ? 'Sin descripción disponible.'
                            : movie.overview,
                        style: textTheme.bodySmall,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String? url;

  const _Poster({required this.url});

  @override
  Widget build(BuildContext context) {
    const double width = 105;
    const double height = 160;

    if (url == null) {
      return const _PosterPlaceholder(width: width, height: height);
    }

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          width: width,
          height: height,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (_, __, ___) =>
          const _PosterPlaceholder(width: width, height: height),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const _PosterPlaceholder({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Icon(Icons.movie, size: 40, color: Colors.grey),
    );
  }
}
