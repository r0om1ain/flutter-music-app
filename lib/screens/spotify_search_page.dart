import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpotifySearchPage extends StatefulWidget {
  @override
  _SpotifySearchPageState createState() => _SpotifySearchPageState();
}

class _SpotifySearchPageState extends State<SpotifySearchPage> {
  String? _accessToken;
  List<dynamic> _tracks = [];
  final TextEditingController _controller = TextEditingController();
  final String userId = "demo_user";

  Future<void> authenticate() async {
    final clientId = '6e5580773ce1412d87f0eede53dc2338';
    final clientSecret = '38dd2e37e2e44b869c04e6e779de5f2a';
    final redirectUri = 'mymusicapp://callback';
    final scopes = 'user-read-private';

    final authUrl =
        'https://accounts.spotify.com/authorize?response_type=code'
        '&client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&scope=$scopes';

    print('AUTH URL: $authUrl');

    final result = await FlutterWebAuth.authenticate(
      url: authUrl,
      callbackUrlScheme: 'mymusicapp',
    );

    final code = Uri.parse(result).queryParameters['code'];

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$clientId:$clientSecret')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code!,
        'redirect_uri': redirectUri,
      },
    );

    setState(() {
      _accessToken = jsonDecode(response.body)['access_token'];
    });
  }

  Future<void> searchTracks(String query) async {
    if (_accessToken == null) return;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    final data = jsonDecode(response.body);
    setState(() {
      _tracks = data['tracks']['items'];
    });
  }

  Future<void> playTrack(String uri) async {
    try {
      await SpotifySdk.connectToSpotifyRemote(
        clientId: '6e5580773ce1412d87f0eede53dc2338',
        redirectUrl: 'mymusicapp://callback',
      );
      await SpotifySdk.play(spotifyUri: uri);
    } catch (e) {
      print('Erreur lecture : $e');
    }
  }

  Future<void> toggleFavorite(dynamic track) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(track['id']);

    final snapshot = await docRef.get();

    if (snapshot.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'title': track['name'],
        'artist': (track['artists'] as List)
            .map((a) => a['name'] as String)
            .join(', '),
        'image': track['album']['images'][0]['url'],
        'uri': track['uri'],
      });
    }

    setState(() {});
  }

  Future<bool> isFavorite(String trackId) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(trackId);
    final snapshot = await docRef.get();
    return snapshot.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche Spotify'),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: authenticate,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_accessToken == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Connectez-vous à Spotify pour commencer.'),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Rechercher un titre',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => searchTracks(_controller.text),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tracks.length,
                itemBuilder: (context, index) {
                  final track = _tracks[index];
                  return FutureBuilder<bool>(
                    future: isFavorite(track['id']),
                    builder: (context, snapshot) {
                      final favorite = snapshot.data ?? false;
                      return ListTile(
                        leading: Image.network(track['album']['images'][0]['url']),
                        title: Text(track['name']),
                        subtitle: Text(
                          (track['artists'] as List)
                              .map((a) => a['name'] as String)
                              .join(', '),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.play_arrow),
                              onPressed: () => playTrack(track['uri']),
                            ),
                            IconButton(
                              icon: Icon(
                                favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: favorite ? Colors.red : null,
                              ),
                              onPressed: () => toggleFavorite(track),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
