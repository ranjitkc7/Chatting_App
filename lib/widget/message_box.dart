import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/date_util.dart';
import 'package:we_chat/main.dart';
import '../models/message.dart';
import '../models/chat_users.dart';

import 'audio_bubble.dart';
import 'text_bubble.dart';
import 'image_bubble.dart';

class MessageBox extends StatefulWidget {
  final Message message;
  final ChatUsers otherUser;

  const MessageBox({
    super.key,
    required this.message,
    required this.otherUser,
  });

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _sendMessage()
        : _receiveMessage();
  }

  Widget _sendMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04,
          vertical: mq.height * 0.003,
        ),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: mq.width * 0.75),
        decoration: const BoxDecoration(
          color: Color(0xFF3AAA35),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _messageContent(),

            const SizedBox(height: 6),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateUtil.getFormattedTime(
                    context: context,
                    time: widget.message.sent,
                  ),
                  style:
                      const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(width: 4),
                Icon(
                  widget.message.read.isEmpty
                      ? Icons.done
                      : Icons.done_all,
                  size: 16,
                  color: widget.message.read.isEmpty
                      ? Colors.white60
                      : Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiveMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message, widget.otherUser);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04,
          vertical: mq.height * 0.003,
        ),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: mq.width * 0.75),
        decoration: const BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _messageContent(),

            const SizedBox(height: 6),

            Text(
              DateUtil.getFormattedTime(
                context: context,
                time: widget.message.sent,
              ),
              style:
                  const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }


  Widget _messageContent() {
    switch (widget.message.type) {
      case Type.text:
        return TextBubble(text: widget.message.msg);

      case Type.image:
        return ImageBubble(imageUrl: widget.message.msg);

      case Type.audio:
        return AudioBubble(audioUrl: widget.message.msg);
    }
  }
}
