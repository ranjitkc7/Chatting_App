import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioBubble extends StatefulWidget {
  final String audioUrl;

  const AudioBubble({super.key, required this.audioUrl});

  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              if (_isPlaying) {
                await _player.pause();
              } else {
                await _player.play(UrlSource(widget.audioUrl));
              }
            },
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          const Text("Voice message", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
