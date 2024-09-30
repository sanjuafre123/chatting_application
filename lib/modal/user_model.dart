import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? name, email, image, phone, token;
  late Timestamp timestamp;
  late bool isOnline, isTyping;

  UserModel({
    required this.name,
    required this.email,
    required this.image,
    required this.token,
    required this.timestamp,
    required this.isOnline,
    required this.isTyping,
  });

  factory UserModel.fromMap(Map m1) {
    return UserModel(
      name: m1['name'],
      email: m1['email'],
      image: m1['image'],
      token: m1['token'],
      timestamp: m1['timestamp'],
      isOnline: m1['isOnline'] ?? false,
      isTyping: m1['isTyping'] ?? false,
    );
  }

  Map<String, String?> toMap(UserModel user) {
    return {
      'name': user.name,
      'email': user.email,
      'image': user.image,
      'token': user.token,
    };
  }
}
