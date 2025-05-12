import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/track.dart';

class FavoritesProvider with ChangeNotifier {
  List<Track> _favorites = [];
  final _firestore = FirebaseFirestore.instance;

  List<Track> get favorites => _favorites;

  Future<void> toggleFavorite(Track track) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('tracks')
        .doc(track.id);

    if (isFavorite(track.id)) {
      await docRef.delete();
      _favorites.removeWhere((t) => t.id == track.id);
    } else {
      await docRef.set(track.toJson());
      _favorites.add(track);
    }
    notifyListeners();
  }

  bool isFavorite(String id) => _favorites.any((t) => t.id == id);

  Future<void> loadFromStorage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('tracks')
        .get();

    _favorites = snap.docs.map((doc) => Track.fromJson(doc.data())).toList();
    notifyListeners();
  }
}