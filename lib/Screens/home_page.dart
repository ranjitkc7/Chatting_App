import 'package:flutter/material.dart';
import '../helper/chat_ui.dart';
import '../models/chat_users.dart';
import '../api/apis.dart';
import 'profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUsers> _list = [];
  final List<ChatUsers> _searchList = [];

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // App Bar
        appBar: AppBar(
          leading: Icon(Icons.home),
          title: _isSearching
              ? TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
      
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  autofocus: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                  onChanged: (value) {
                    _searchList.clear();
      
                    for (var user in _list) {
                      if (user.name.toLowerCase().contains(value.toLowerCase()) ||
                          user.email.toLowerCase().contains(
                            value.toLowerCase(),
                          )) {
                        _searchList.add(user);
                      }
                      setState(() {
                        _searchList;
                      });
                    }
                  },
                )
              : Text("We Chat"),
          actions: [
            // Search
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
              icon: Icon(!_isSearching ? Icons.search : Icons.clear_rounded),
            ),
            // More Options
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(users: APIs.me),
                  ),
                );
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        // floating action button
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(
            Icons.add_comment_rounded,
            size: 30,
            color: Color(0xFF3AAA35),
          ),
        ),
      
        body: StreamBuilder(
          stream: APIs.getAllUsers(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                break;
            }
      
            if (snapshot.hasData) {
              final data = snapshot.data?.docs;
      
              _list =
                  data?.map((e) => ChatUsers.fromJson(e.data())).toList() ?? [];
      
              return ListView.builder(
                itemCount: _isSearching ? _searchList.length : _list.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return ChatUIPage(
                    users: _isSearching ? _searchList[index] : _list[index],
                  );
                },
              );
            }
            return const Center(child: Text("No Users Found!"));
          },
        ),
      ),
    );
  }
}
