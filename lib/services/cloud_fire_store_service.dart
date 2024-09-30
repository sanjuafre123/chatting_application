import 'dart:developer';

import 'package:chat_app/modal/chat_modal.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../modal/user_model.dart';

class CloudFireStoreService {
  CloudFireStoreService._();

  static CloudFireStoreService cloudFireStoreService =
      CloudFireStoreService._();

  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  void insertUserIntoFireStore(UserModel user) {
    fireStore.collection("users").doc(user.email).set({
      'email': user.email,
      'name': user.name,
      'token': user.token,
      'image': user.image,
      'timestamp': Timestamp.now(),
      'isOnline': false,
      'isTyping': false,
    });
  }

  // Read data for current user - profile

  Future<DocumentSnapshot<Map<String, dynamic>>>
      readCurrentUserFromFireStore() async {
    User? user = AuthService.authService.getCurrentUser();
    return await fireStore.collection("users").doc(user!.email).get();
  }

  //read all user from fire store
  Future<QuerySnapshot<Map<String, dynamic>>>
      readAllUserFromCloudFireStore() async {
    User? user = AuthService.authService.getCurrentUser();
    return await fireStore
        .collection("users")
        .where("email", isNotEqualTo: user!.email)
        .get();
  }

  // ADD CHAT IN FIRE STORE
  Future<void> addChatInFireStore(ChatModal chat) async {
    String? sender = chat.sender;
    String? receiver = chat.receiver;
    List doc = [sender, receiver];
    doc.sort();
    String docId = doc.join("_");

    await fireStore
        .collection("chatroom")
        .doc(docId)
        .collection("chat")
        .add(chat.toMap(chat));
  }

  // READ MESSAGE IN FIRE STORE

  Stream<QuerySnapshot<Map<String, dynamic>>> readChatFromFireStore(
      String receiver) {
    String sender = AuthService.authService.getCurrentUser()!.email!;
    List doc = [sender, receiver];
    doc.sort();
    String docId = doc.join("_");
    return fireStore
        .collection("chatroom")
        .doc(docId)
        .collection("chat")
        .orderBy("time", descending: false)
        .snapshots();
  }

  // UPDATE MESSAGE IN FIRE STORE

  Future<void> updateChat(String receiver, String message, String dcId) async {
    String sender = AuthService.authService.getCurrentUser()!.email!;
    List doc = [sender, receiver];
    doc.sort();
    String docId = doc.join("_");
    await fireStore
        .collection("chatroom")
        .doc(docId)
        .collection("chat")
        .doc(dcId)
        .update({'message': message});
  }

  // DELETE MESSAGE IN FIRE STORE

  Future<void> removeChat(String dcId, String receiver) async {
    String sender = AuthService.authService.getCurrentUser()!.email!;
    List doc = [sender, receiver];
    doc.sort();
    String docId = doc.join("_");
    await fireStore
        .collection("chatroom")
        .doc(docId)
        .collection("chat")
        .doc(dcId)
        .delete();
  }

  // CHANGE ONLINE STATUS

  Future<void> changeOnlineStatus(bool status, Timestamp timestamp, bool isTyping) async {
    String email = AuthService.authService.getCurrentUser()!.email!;

    await fireStore.collection("users").doc(email).update({
      'isOnline': status,
      'timestamp': timestamp,
      'isTyping': isTyping,
    });

    final snapshot = await fireStore.collection("users").doc(email).get();
    Map? user = snapshot.data();
    log("user online status after $status : ${user!['isOnline']}");
   }

  // FIND USER IS ONLINE OR NOT
  Stream<DocumentSnapshot<Map<String, dynamic>>> findUserIsOnlineNot(
      String email) {
    return fireStore.collection("users").doc(email).snapshots();
  }
}
