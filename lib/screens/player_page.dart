import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerPage extends StatefulWidget {
  final String title;
  final String artist;
  final String image;
  final String audioUrl;

  const PlayerPage({
    required this.title,
    required this.artist,
    required this.image,
    required this.audioUrl,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late AudioPlayer _player;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _player.setUrl(widget.audioUrl);
    } catch (e) {
      print('Erreur chargement audio : $e');
    }
  }

  void _togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    setState(() => isPlaying = _player.playing);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(widget.image, height: 200),
          const SizedBox(height: 20),
          Text(widget.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(widget.artist, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 40),
          IconButton(
            iconSize: 64,
            icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
            onPressed: _togglePlayback,
          ),
        ],
      ),
    );
  }
}
