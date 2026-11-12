import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MovieRecommenderApp());
}

class MovieRecommenderApp extends StatelessWidget {
  const MovieRecommenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recomendador de Películas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}
