import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/models/message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../models/chat_users.dart';

class APIs {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();

  // Current user (⚠️ use carefully)
  static User get user => auth.currentUser!;

  static late ChatUsers me;

  // Check if user exists in Firestore
  static Future<bool> userExists() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((
      userDoc,
    ) async {
      if (userDoc.exists) {
        // ✅ Set the current user info
        me = ChatUsers.fromJson(userDoc.data()!);

        // ✅ Get FCM token and save it
        await getFirebaseMessagingToken();
      } else {
        // If user doesn't exist, create it and recall getSelfInfo
        await createUsers().then((value) => getSelfInfo());
      }
    });
  }

  // Create user in Firestore
  static Future<void> createUsers() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUsers = ChatUsers(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      imageUrl: user.photoURL ?? '',
      about: "Hey, I'm using We Chat.",
      createdAt: time,
      isActive: time,
      isOnline: false,
      pushToken: '',
    );

    await firestore.collection("users").doc(user.uid).set(chatUsers.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection("users")
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    return await firestore.collection("users").doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
    ChatUsers users,
  ) {
    return firestore
        .collection("chats/${getConversationID(users.id)}/messages/")
        .orderBy('sent', descending: false)
        .snapshots();
  }

  static Future<void> sendMessage(ChatUsers chatUser, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = firestore
        .collection("chats/${getConversationID(chatUser.id)}/messages/")
        .doc(time);

    final Message message = Message(
      id: time,
      fromId: user.uid,
      toId: chatUser.id,
      msg: msg,
      type: Type.text,
      sent: time,
      read: "",
    );

    await ref.set(message.toJson());

    await sendPushNotification(chatUser, me.name, msg);
  }

  static Future<void> updateMessageReadStatus(
    Message message,
    ChatUsers otherUser,
  ) async {
    if (message.read.isEmpty && message.fromId != user.uid) {
      await firestore
          .collection("chats/${getConversationID(otherUser.id)}/messages/")
          .doc(message.id)
          .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
    ChatUsers user,
  ) {
    return firestore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> markAllMessagesAsRead(ChatUsers otherUser) async {
    final ref = firestore.collection(
      "chats/${getConversationID(otherUser.id)}/messages/",
    );

    final snapshot = await ref
        // ✅ ONLY messages SENT BY OTHER USER
        .where('fromId', isEqualTo: otherUser.id)
        // ✅ ONLY messages RECEIVED BY ME
        .where('toId', isEqualTo: user.uid)
        // ✅ ONLY UNREAD messages
        .where('read', isEqualTo: '')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({
        'read': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    }
  }

  static Future<void> getFirebaseMessagingToken() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    final token = await fcm.getToken();

    if (token != null) {
      me.pushToken = token;

      await firestore.collection('users').doc(user.uid).update({
        'pushToken': token,
      });
    }
  }

  static Future<void> sendPushNotification(
    ChatUsers chatUser,
    String title,
    String body,
  ) async {
    if (chatUser.pushToken.isEmpty) return;

    final data = {
      "to": chatUser.pushToken,
      'notification': {
        "title": title,
        "body": body,
        "android_channel_id": "chats",
      },
      "data": {"senderId": user.uid},
    };

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=YOUR_SERVER_KEY_FROM_FIREBASE',
      },
      body: jsonEncode(data),
    );
  }
}
