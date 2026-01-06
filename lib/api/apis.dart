import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/models/message.dart';

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
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUsers.fromJson(user.data()!);
      } else {
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
        .snapshots();
  }

  static Future<void> sendMessage(ChatUsers chatUser, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
      fromId: user.uid,
      toId: chatUser.id,
      msg: msg,
      type: Type.text,
      sent: time,
      read: "",
    );
    final ref = firestore.collection(
      "chats/${getConversationID(chatUser.id)}/messages/",
    );
    await ref.doc().set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    await firestore
        .collection("chats/${getConversationID(message.fromId)}/messages/")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }
}
