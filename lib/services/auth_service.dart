import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService {
  AuthService._();

  static AuthService authService = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Account Create - Sign Up

  Future<UserCredential> createAccountUsingEmailAndPassword(
      String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Get.snackbar('Invalid!', e.code);
    }
  }

  Future<UserCredential> signInUsingEmailAndPassword(
      String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Get.snackbar('Invalid!', 'Invalid password or email!');
    }
  }

  //Sign Out
  Future<void> signOutUser() async {
    await _firebaseAuth.signOut();
  }

  // Get Current User

  User? getCurrentUser() {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      log("email : ${user.email}");
    }
    return user;
  }
}
