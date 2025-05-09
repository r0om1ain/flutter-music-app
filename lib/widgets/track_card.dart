import 'package:flutter/material.dart';
import '../models/track.dart';

class TrackCard extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const TrackCard({
    required this.track,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(track.coverUrl, width: 50),
      title: Text(track.title),
      subtitle: Text(track.artist),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
        onPressed: onFavoriteToggle,
      ),
      onTap: onTap,
    );
  }
}