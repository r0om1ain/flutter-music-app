// 📁 lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/track_card.dart';
import '../screens/player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoritesProvider>(context);
    final favorites = favProvider.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: favorites.isEmpty
          ? const Center(child: Text("Aucun favori pour l'instant."))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (ctx, i) => TrackCard(
          track: favorites[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerScreen(track: favorites[i]),
            ),
          ),
          isFavorite: true,
          onFavoriteToggle: () =>
              favProvider.toggleFavorite(favorites[i]),
        ),
      ),
    );
  }
}