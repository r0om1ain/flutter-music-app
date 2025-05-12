// 📁 lib/screens/player_screen.dart
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
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();

    _player.positionStream.listen((p) {
      setState(() => _position = p);
    });

    _player.durationStream.listen((d) {
      if (d != null) setState(() => _duration = d);
    });
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(widget.track.coverUrl),
            const SizedBox(height: 20),
            Text(widget.track.title, style: Theme.of(context).textTheme.titleLarge),
            Text(widget.track.artist),
            const SizedBox(height: 20),
            Slider(
              value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
              max: _duration.inSeconds.toDouble(),
              onChanged: (val) => _player.seek(Duration(seconds: val.toInt())),
            ),
            Text(
              "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 20),
            IconButton(
              iconSize: 64,
              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
              onPressed: _togglePlayback,
            ),
          ],
        ),
      ),
    ),
  );

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
