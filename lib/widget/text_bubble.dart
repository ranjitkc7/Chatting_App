import 'package:flutter/material.dart';

class TextBubble extends StatelessWidget {
  final String text;

  const TextBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, color: Colors.white),
    );
  }
}
