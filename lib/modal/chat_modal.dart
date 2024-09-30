import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModal {
  String? sender, receiver, message;
  Timestamp time;

  ChatModal(
      {required this.sender,
      required this.receiver,
      required this.message,
      required this.time});

  factory ChatModal.fromMap(Map m1) {
    return ChatModal(
      sender: m1['sender'],
      receiver: m1['receiver'],
      message: m1['message'],
      time: m1['time'],
    );
  }

  Map<String, dynamic> toMap(ChatModal chat) {
    return {
      'sender': chat.sender,
      'receiver': chat.receiver,
      'message': chat.message,
      'time': chat.time,
    };
  }
}
