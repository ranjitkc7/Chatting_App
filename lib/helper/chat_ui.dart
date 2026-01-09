// ignore_for_file: unnecessary_null_comparison, unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/Screens/chatScreen_page.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/message.dart';
import '../models/chat_users.dart';

class ChatUIPage extends StatefulWidget {
  final ChatUsers users;

  const ChatUIPage({super.key, required this.users});

  @override
  State<ChatUIPage> createState() => _ChatUIPageState();
}

class _ChatUIPageState extends State<ChatUIPage> {
  Message? _lastMessage;

  String getTimeAgo(String sentTime) {
    final sentMillis = int.tryParse(sentTime);
    if (sentMillis == null) return "";
    final sentDate = DateTime.fromMillisecondsSinceEpoch(sentMillis);
    final now = DateTime.now();
    final diff = now.difference(sentDate);

    if (diff.inSeconds < 60) return "${diff.inSeconds}s";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    return "${diff.inDays}d";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreenPage(users: widget.users),
            ),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.users),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;

            // Convert Firestore docs to Message objects
            final list =
                data?.map((e) => Message.fromJson(e.data(), e.id)).toList() ??
                [];

            if (list.isNotEmpty) {
              _lastMessage = list[0];
            } else {
              _lastMessage = null;
            }

            bool isUnread =
                _lastMessage != null &&
                _lastMessage!.fromId != APIs.user.uid && // sent by other user
                _lastMessage!.toId == APIs.user.uid && // sent to me
                _lastMessage!.read.isEmpty;

            String? trailingText;
            if (_lastMessage != null && _lastMessage!.fromId == APIs.user.uid) {
              trailingText = getTimeAgo(_lastMessage!.sent);
            }

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.3),
                child: CachedNetworkImage(
                  height: mq.width * 0.10,
                  width: mq.width * 0.10,
                  imageUrl: widget.users.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Icon(Icons.person, color: Color(0xFF3AAA35)),
                  ),
                ),
              ),
              title: Text(
                widget.users.name,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                _lastMessage?.msg ?? widget.users.about,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: _lastMessage == null
                  ? null
                  : (_lastMessage!.fromId == APIs.user.uid
                        ? Text(
                            getTimeAgo(_lastMessage!.sent),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 170, 158, 158),
                            ),
                          )
                        : isUnread
                        ? Container(
                            width: 11,
                            height: 11,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 5, 164, 11),
                              shape: BoxShape.circle,
                            ),
                          )
                        : null),
            );
          },
        ),
      ),
    );
  }
}
