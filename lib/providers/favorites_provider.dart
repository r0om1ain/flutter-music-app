import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track.dart';
import 'dart:convert';

class FavoritesProvider with ChangeNotifier {
  List<Track> _favorites = [];

  List<Track> get favorites => _favorites;

  void toggleFavorite(Track track) {
    if (_favorites.any((t) => t.id == track.id)) {
      _favorites.removeWhere((t) => t.id == track.id);
    } else {
      _favorites.add(track);
    }
    _saveToStorage();
    notifyListeners();
  }

  bool isFavorite(String id) => _favorites.any((t) => t.id == id);

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('favorites');
    if (jsonStr != null) {
      final List decoded = json.decode(jsonStr);
      _favorites = decoded.map((e) => Track.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('favorites', json.encode(_favorites.map((e) => e.toJson()).toList()));
  }
}