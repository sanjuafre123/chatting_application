import 'dart:developer';

import 'package:chat_app/modal/user_model.dart';
import 'package:chat_app/services/cloud_fire_store_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static GoogleAuthService googleAuthService = GoogleAuthService._();

  GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      GoogleSignInAccount? account = await googleSignIn.signIn();

      GoogleSignInAuthentication authentication = await account!.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      CloudFireStoreService.cloudFireStoreService.insertUserIntoFireStore(
        UserModel(
          name: userCredential.user!.displayName,
          email: userCredential.user!.email,
          image: userCredential.user!.photoURL,
          token: '',
          timestamp: Timestamp.now(),
          isOnline: false,
          isTyping: false,
        ),
      );

      log(userCredential.user!.email!);
      log(userCredential.user!.photoURL!);
    } catch (e) {
      Get.snackbar("Google sign Failed", e.toString());
      log(e.toString());
    }
  }

  Future<void> signOutFromGoogle() async {
    await googleSignIn.signOut();
  }
}


// ssh-keygen -t ed25519 -C "sanjuafre08@gmail.com"