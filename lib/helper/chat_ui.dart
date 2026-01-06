import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/Screens/chatScreen_page.dart';
import 'package:we_chat/main.dart';
import '../models/chat_users.dart';

class ChatUIPage extends StatefulWidget {
  final ChatUsers users;

  const ChatUIPage({super.key, required this.users});

  @override
  State<ChatUIPage> createState() => _ChatUIPageState();
}

class _ChatUIPageState extends State<ChatUIPage> {
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
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: CachedNetworkImage(
              height: mq.width * 0.10,
              width: mq.width * 0.10,
              imageUrl: widget.users.imageUrl,
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => CircleAvatar(
                child: Icon(Icons.person, color: Color(0xFF3AAA35)),
              ),
            ),
          ),
          title: Text(widget.users.name),
          subtitle: Text(widget.users.about, maxLines: 1),
          // trailing: const Text(
          //   "12:00 PM",
          //   style: TextStyle(
          //     color: Color.fromARGB(255, 74, 64, 64),
          //     fontSize: 12,
          //   ),
          // ),
          trailing: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 5, 164, 11),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
