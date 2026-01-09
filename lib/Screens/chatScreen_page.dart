import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/message_box.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_users.dart';
import 'package:we_chat/models/message.dart';

class ChatScreenPage extends StatefulWidget {
  final ChatUsers users;

  const ChatScreenPage({super.key, required this.users});

  @override
  State<ChatScreenPage> createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
void initState() {
  super.initState();
  APIs.markAllMessagesAsRead(widget.users);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: APIs.getAllMessage(widget.users),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const SizedBox();
                  }
        
                  final data = snapshot.data?.docs;
                  _list =
                      data
                          ?.map((e) => Message.fromJson(e.data(), e.id))
                          .toList() ??
                      [];
        
                  // Auto-scroll to latest message
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });
        
                  if (_list.isEmpty) {
                    return const Center(
                      child: Text("Say Hii!", style: TextStyle(fontSize: 22)),
                    );
                  }
        
                  return ListView.builder(
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    itemCount: _list.length,
                    itemBuilder: (context, index) {
                      return MessageBox(
                        message: _list[index],
                        otherUser: widget.users,
                      );
                    },
                  );
                },
              ),
            ),
        
            _chatInput(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return Container(
      padding: EdgeInsets.only(top: mq.height * 0.04, left: 0, right: 5),
      color: Color(0xFF3AAA35),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),

          // Profile Picture with border and online indicator
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    height: mq.height * 0.06,
                    width: mq.height * 0.06,
                    fit: BoxFit.cover,
                    imageUrl: widget.users.imageUrl,
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: mq.height * 0.04,
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
              ),
              // Online Indicator
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: widget.users.isOnline
                        ? Colors.green
                        : const Color.fromARGB(255, 224, 220, 220),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 15),

          // Name & Last Seen
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.users.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  widget.users.isOnline ? "Online" : "Last seen recently",
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color.fromARGB(255, 244, 233, 233),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.call, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.videocam, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _chatInput() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        child: Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.settings_voice,
                        size: 26,
                        color: Color(0xFF3AAA35),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Type somethings..",
                          hintStyle: TextStyle(color: Color(0xFF3AAA35)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        size: 26,
                        color: Color(0xFF3AAA35),
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.image,
                        size: 26,
                        color: Color(0xFF3AAA35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  APIs.sendMessage(widget.users, _textController.text);
                  _textController.text = "";
                }
              },
              shape: CircleBorder(),
              minWidth: 0,
              padding: EdgeInsets.only(top: 10, bottom: 10, right: 2, left: 5),
              color: Color(0xFF3AAA35),
              child: Icon(Icons.send, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
