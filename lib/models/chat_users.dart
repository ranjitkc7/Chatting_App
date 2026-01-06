class ChatUsers {
  String id;
  String name;
  String email;
  String imageUrl;
  String about;
  String createdAt;
  String isActive;
  bool isOnline;
  String pushToken;

  ChatUsers({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.about,
    required this.createdAt,
    required this.isActive,
    required this.isOnline,
    required this.pushToken,
  });

  factory ChatUsers.fromJson(Map<String, dynamic> json) {
    return ChatUsers(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      about: json['about'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isActive: json['isActive'] ?? '',
      isOnline: json['isOnline'] ?? false,
      pushToken: json['push_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'about': about,
      'createdAt': createdAt,
      'isActive': isActive,
      'isOnline': isOnline,
      'push_token': pushToken,
    };
  }
}
