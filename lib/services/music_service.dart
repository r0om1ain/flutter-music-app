import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';

class MusicService {
  Future<List<Track>> fetchTracksByGenre(String genre) async {
    final url = Uri.parse('https://api.deezer.com/search?q=genre:"$genre"');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List data = json.decode(res.body)['data'];
      return data.map((e) => Track.fromJson(e)).toList();
    } else {
      throw Exception('Erreur API Deezer');
    }
  }
}