import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_service.dart';
import '../models/track.dart';
import '../widgets/track_card.dart';
import '../providers/favorites_provider.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _musicService = MusicService();
  List<Track> _tracks = [];
  final List<String> _genres = ['pop', 'rock', 'rap', 'electro'];
  String _selectedGenre = 'pop';

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    final tracks = await _musicService.fetchTracksByGenre(_selectedGenre);
    setState(() => _tracks = tracks);
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Musiques par genre',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedGenre,
              decoration: InputDecoration(
                labelText: 'Sélectionne un genre',
                labelStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              icon: const Icon(Icons.arrow_drop_down),
              items: _genres
                  .map((g) => DropdownMenuItem(
                value: g,
                child: Text(g.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w500)),
              ))
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedGenre = val!;
                _loadTracks();
              }),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _tracks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _tracks.length,
              itemBuilder: (ctx, i) {
                final t = _tracks[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TrackCard(
                    track: t,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlayerScreen(track: t)),
                    ),
                    isFavorite: favProvider.isFavorite(t.id),
                    onFavoriteToggle: () => favProvider.toggleFavorite(t),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
