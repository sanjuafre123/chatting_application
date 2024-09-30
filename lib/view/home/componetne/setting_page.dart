import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../modal/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/cloud_fire_store_service.dart';
import '../../../services/google_auth_service.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Details"),
        centerTitle: true,
        leading: InkWell(
            onTap: () {
              Get.offAndToNamed('/home');
            },
            child: Icon(Icons.arrow_back)),
      ),
      body: FutureBuilder(
        future: CloudFireStoreService.cloudFireStoreService
            .readCurrentUserFromFireStore(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Map? data = snapshot.data!.data();
          UserModel userModel = UserModel.fromMap(data!);
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage('${userModel.image}'),
                          radius: 35,
                        ),
                        GestureDetector(
                          onTap: () async {},
                          child: const Padding(
                            padding: EdgeInsets.only(left: 46, top: 35),
                            child: Icon(
                              CupertinoIcons.camera_fill,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      '   ${userModel.name}',
                      style: GoogleFonts.vollkorn(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(
                      '    ${userModel.email}',
                      style: GoogleFonts.monda(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 25,
                  ),
                  SettingsTile(
                      icon: Icons.vpn_key,
                      title: 'Account',
                      subtitle: 'Security notifications, change number'),
                  SettingsTile(
                      icon: Icons.lock,
                      title: 'Privacy',
                      subtitle: 'Block contacts, disappearing messages'),
                  SettingsTile(
                      icon: Icons.icecream_outlined,
                      title: 'Theme',
                      subtitle: 'Light Theme,  Dark Theme'),
                  SettingsTile(
                      icon: Icons.favorite,
                      title: 'Favourites',
                      subtitle: 'Add, reorder, remove'),
                  SettingsTile(
                      icon: Icons.chat,
                      title: 'Chats',
                      subtitle: 'Theme, wallpapers, chat history'),
                  SettingsTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Message, group & call tones'),
                  SettingsTile(
                      icon: Icons.data_usage,
                      title: 'Storage and data',
                      subtitle: 'Network usage, auto-download'),
                  SettingsTile(
                      icon: Icons.language,
                      title: 'App language',
                      subtitle: 'English (device\'s language)'),
                  InkWell(
                    onTap: () async {
                      await AuthService.authService.signOutUser();
                      await GoogleAuthService.googleAuthService
                          .signOutFromGoogle();
                      User? user = AuthService.authService.getCurrentUser();
                      if (user == null) {
                        Get.offAndToNamed('/signIn');
                      }
                    },
                    child: SettingsTile(
                        icon: Icons.logout,
                        title: 'Log out',
                        subtitle: 'Log out to your device',
                        iconColor: Colors.red), // Red log out icon
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

ListTile SettingsTile(
    {required IconData icon,
      required String title,
      required String subtitle,
      Color iconColor = Colors.black}) {
  return ListTile(
    leading: Icon(icon, color: iconColor),
    title: Text(
      title,
      style: GoogleFonts.aBeeZee(fontSize: 18),
    ),
    subtitle: Text(
      subtitle,
      style: GoogleFonts.leagueSpartan(fontSize: 16),
    ),
  );
}
