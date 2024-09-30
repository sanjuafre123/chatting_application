import 'package:chat_app/services/fire_messaging_service.dart';
import 'package:chat_app/services/local_notification_service.dart';
import 'package:chat_app/view/auth/auth_manager.dart';
import 'package:chat_app/view/auth/sign_in.dart';
import 'package:chat_app/view/auth/sign_up.dart';
import 'package:chat_app/view/home/chat_page.dart';
import 'package:chat_app/view/home/componetne/setting_page.dart';
import 'package:chat_app/view/home/home_page.dart';
import 'package:chat_app/view/home/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotificationService.notificationService.initNotificationService();
  await FirebaseMessagingService.firebaseMessagingService.requestPermission();
  await FirebaseMessagingService.firebaseMessagingService.getDeviceToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/Auth', page: () => const AuthManager()),
        GetPage(name: '/signIn', page: () => const SignIn()),
        GetPage(name: '/SignUp', page: () => const SignUp()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/chat', page: () => const ChatPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
      ],
    );
  }
}
