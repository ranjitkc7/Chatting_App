class Message {
  final String fromId;
  final String toId;
  final String msg;
  final Type type;
  final String sent;
  final String read;

  Message({
    required this.fromId,
    required this.toId,
    required this.msg,
    required this.type,
    required this.sent,
    required this.read,
  });

  // 🔹 From Firestore (JSON → Dart)
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      fromId: json['fromId'].toString(),
      toId: json['told'].toString(),
      msg: json['msg'].toString(),
      type: json['type'].toString() == Type.image.name ? Type.image : Type.text,
      sent: json['sent'].toString(),
      read: json['read'].toString(),
    );
  }

  // 🔹 To Firestore (Dart → JSON)
  Map<String, dynamic> toJson() {
    return {
      'fromId': fromId,
      'told': toId,
      'msg': msg,
      'type': type.name,
      'sent': sent,
      'read': read,
    };
  }
}

enum Type { text, image }
