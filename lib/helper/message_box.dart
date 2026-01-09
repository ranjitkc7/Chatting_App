import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/date_util.dart';
import 'package:we_chat/main.dart';
import '../models/message.dart';
import '../models/chat_users.dart';

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
  final bool _updated = false;

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: mq.width * 0.75),
        decoration: BoxDecoration(
          color: const Color(0xFF3AAA35),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateUtil.getFormattedTime(
                    context: context,
                    time: widget.message.sent,
                  ),
                  style:
                      const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(width: 5),
                Icon(
                  widget.message.read.isEmpty
                      ? Icons.done_rounded
                      : Icons.done_all_rounded,
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04,
          vertical: mq.height * 0.003,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: mq.width * 0.75),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 5),
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
}
