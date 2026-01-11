import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/widget/message_box.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_users.dart';
import 'package:we_chat/models/message.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../helper/date_util.dart' show DateUtil;

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

  final AudioRecorder _record = AudioRecorder();

  bool _isRecording = false;
  bool _hasRecordedAudio = false;
  String? _audioPath;

  Future<void> _startRecording() async {
    if (await _record.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      _audioPath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _record.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _audioPath!,
      );

      setState(() {
        _isRecording = true;
        _hasRecordedAudio = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _record.stop();

    if (path != null) {
      setState(() {
        _isRecording = false;
        _hasRecordedAudio = true;
        _audioPath = path;
      });
    }
  }

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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: APIs.getAllMessage(widget.users),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final data = snapshot.data!.docs;
                _list = data
                    .map((e) => Message.fromJson(e.data(), e.id))
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                if (_list.isEmpty) {
                  return const Center(
                    child: Text("Say Hi!", style: TextStyle(fontSize: 22)),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
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
    );
  }

  Widget _appBar() {
    return Container(
      padding: EdgeInsets.only(top: mq.height * 0.04, right: 5),
      color: const Color(0xFF3AAA35),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  height: mq.height * 0.055,
                  width: mq.height * 0.055,
                  fit: BoxFit.cover,
                  imageUrl: widget.users.imageUrl,
                  errorWidget: (_, __, ___) =>
                      const CircleAvatar(child: Icon(Icons.person)),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: widget.users.isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 👤 USER NAME
              Text(
                widget.users.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.users.isOnline
                    ? "Online"
                    : DateUtil.getLastActiveTime(
                        context: context,
                        lastActive: widget.users.lastActive,
                      ),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            
            ],
          ),
          ),
        ],
      ),
    );
  }

  // ================= CHAT INPUT =================
  Widget _chatInput() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  // 🎙 MIC BUTTON
                  IconButton(
                    onPressed: () {
                      if (_isRecording) {
                        _stopRecording();
                      } else {
                        _startRecording();
                      }
                    },
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: const Color(0xFF3AAA35),
                    ),
                  ),

                  Expanded(
                    child: _isRecording
                        ? const Text(
                            "Recording...",
                            style: TextStyle(color: Colors.red),
                          )
                        : _hasRecordedAudio
                        ? const Text(
                            "Voice message ready",
                            style: TextStyle(color: Colors.green),
                          )
                        : TextField(
                            controller: _textController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: "Type something...",
                              border: InputBorder.none,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          MaterialButton(
            shape: const CircleBorder(),
            color: const Color(0xFF3AAA35),
            padding: const EdgeInsets.all(12),
            onPressed: () async {
              // 🔊 SEND AUDIO
              if (_hasRecordedAudio && _audioPath != null) {
                await APIs.sendAudioMessage(widget.users, File(_audioPath!));

                setState(() {
                  _hasRecordedAudio = false;
                  _audioPath = null;
                  _isRecording = false; // ✅ FIX 2
                });
                return;
              }

              // ✉️ SEND TEXT
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.users, _textController.text);
                _textController.clear();
              }
            },
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
