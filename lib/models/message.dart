class Message {
  final String id;
  final String fromId;
  final String toId;
  final String msg;
  final Type type;
  final String sent;
  final String read;

  Message({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.msg,
    required this.type,
    required this.sent,
    required this.read,
  });

  // 🔹 From Firestore (JSON → Dart)
  factory Message.fromJson(Map<String, dynamic> json, String id) {
    return Message(
      id: json['id'] ?? '',
      fromId: json['fromId'] ?? '',
      toId: json['toId'] ?? '',
      msg: json['msg'] ?? '',
      type: json['type'] == Type.image.name ? Type.image : Type.text,
      sent: json['sent'] ?? '',
      read: json['read'] ?? '',
    );
  }

  // 🔹 To Firestore (Dart → JSON)
  Map<String, dynamic> toJson() {
    return {
      'fromId': fromId,
      'toId': toId,
      'msg': msg,
      'type': type.name,
      'sent': sent,
      'read': read,
    };
  }
}

enum Type { text, image }
