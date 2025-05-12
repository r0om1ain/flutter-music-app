import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_service.dart';
import '../models/track.dart';
import '../widgets/track_card.dart';
import '../providers/favorites_provider.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _musicService = MusicService();
  List<Track> _results = [];

  Future<void> _search(String query) async {
    final results = await _musicService.fetchTracksByGenre(query);
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Rechercher un genre (pop, rock, etc)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(_controller.text),
                ),
              ),
              onSubmitted: _search,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (ctx, i) {
                final t = _results[i];
                return TrackCard(
                  track: t,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerScreen(track: t),
                    ),
                  ),
                  isFavorite: favProvider.isFavorite(t.id),
                  onFavoriteToggle: () => favProvider.toggleFavorite(t),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
