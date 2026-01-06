import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/date_util.dart';
import 'package:we_chat/main.dart';
import '../models/message.dart';

class MessageBox extends StatefulWidget {
  final Message message;

  const MessageBox({super.key, required this.message});

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  @override
  Widget build(BuildContext context) {
    // My message → green, others → purple
    return APIs.user.uid == widget.message.fromId
        ? _SendMessage()
        : _ReceiveMessage();
  }
  
  Widget _SendMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04,
          vertical: mq.height * 0.008,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: mq.width * 0.75),
        decoration: BoxDecoration(
          color: Color(0xFF3AAA35),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.message.msg,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateUtil.getFormattedTime(
                    context: context,
                    time: widget.message.sent,
                  ),
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                SizedBox(width: 5),
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

  Widget _ReceiveMessage() {
    // ✅ Update read status only once when the widget is first built
    if (widget.message.read.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        APIs.updateMessageReadStatus(widget.message);
      });
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04,
          vertical: mq.height * 0.008,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: mq.width * 0.75),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message.msg,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 5),
            Text(
              DateUtil.getFormattedTime(
                context: context,
                time: widget.message.sent,
              ),
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
