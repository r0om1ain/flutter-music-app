class Track {
  final String id;
  final String title;
  final String artist;
  final String previewUrl;
  final String coverUrl;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.previewUrl,
    required this.coverUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    final artistField = json['artist'];
    return Track(
      id: json['id'].toString(),
      title: json['title'],
      artist: artistField is Map ? artistField['name'] : artistField.toString(),
      previewUrl: json['preview'],
      coverUrl: json['album'] is Map ? json['album']['cover_medium'] : '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'preview': previewUrl,
      'album': {'cover_medium': coverUrl},
    };
  }
}