import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';

class PlayerScreen extends StatefulWidget {
  final Track track;
  const PlayerScreen({required this.track, super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer _player;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setUrl(widget.track.previewUrl);
      await _player.play();
      setState(() => isPlaying = true);
    } catch (e) {
      print('Erreur audio: $e');
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.track.title)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(widget.track.coverUrl),
          const SizedBox(height: 20),
          Text(widget.track.title, style: Theme.of(context).textTheme.titleLarge),
          Text(widget.track.artist),
          const SizedBox(height: 20),
          IconButton(
            iconSize: 64,
            icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
            onPressed: _togglePlayback,
          ),
        ],
      ),
    ),
  );
}