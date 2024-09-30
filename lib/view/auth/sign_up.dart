import 'package:chat_app/controller/auth_controller.dart';
import 'package:chat_app/modal/user_model.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/cloud_fire_store_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/google_auth_service.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 160),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Custom FadeIn Widget for Text
              FadeIn(
                child: Row(
                  children: [
                    Text(
                      'Create your Account',
                      style: GoogleFonts.exo2(
                          fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 22,
              ),
              // Enhanced Text Fields with Shadow and Rounded Corners
              FadeIn(
                child: _buildTextField(
                  controller: controller.txtName,
                  hintText: 'Name',
                  icon: Icons.person,
                ),
              ),
              const SizedBox(
                height: 22,
              ),
              FadeIn(
                child: _buildTextField(
                  controller: controller.txtEmail,
                  hintText: 'Email',
                  icon: Icons.email,
                ),
              ),
              const SizedBox(
                height: 22,
              ),
              FadeIn(
                child: _buildTextField(
                  controller: controller.txtPassword,
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
              ),
              SizedBox(
                height: 22,
              ),
              FadeIn(
                child: _buildTextField(
                  controller: controller.txtConfirm,
                  hintText: 'Confirm Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
              ),
              const SizedBox(
                height: 22,
              ),
              // Sign-up button with gradient and shadow
              FadeIn(
                child: GestureDetector(
                  onTap: () {
                    if (controller.txtPassword.text ==
                        controller.txtConfirm.text) {
                      AuthService.authService.createAccountUsingEmailAndPassword(
                          controller.txtEmail.text,
                          controller.txtPassword.text);

                      UserModel user = UserModel(
                        name: controller.txtName.text,
                        email: controller.txtEmail.text,
                        image:
                            "https://play-lh.googleusercontent.com/7oW_TFaC5yllHJK8nhxHLQRCvGDE8jYIAc2SWljYpR6hQlFTkbA6lNvER1ZK-doQnQ",
                        token: "---",
                        isTyping: false,
                        isOnline: false,
                        timestamp: Timestamp.now(),
                      );

                      CloudFireStoreService.cloudFireStoreService
                          .insertUserIntoFireStore(user);

                      Get.offAndToNamed('/home');
                      controller.txtEmail.clear();
                      controller.txtName.clear();
                      controller.txtPassword.clear();
                      controller.txtConfirm.clear();
                    }
                  },
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff1f319d),
                          Color(0xff1133a6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 58,
              ),
              FadeIn(
                child: Text(
                  '- Or sign up with -',
                  style: GoogleFonts.exo(
                    wordSpacing: -0.5,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              // Social Media Buttons with Gradient and Shadow
              FadeIn(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialMediaButton(
                      'assets/google.webp',
                      'Google',
                      onTap: () async {
                        await GoogleAuthService.googleAuthService
                            .signInWithGoogle();
                        User? user = AuthService.authService.getCurrentUser();
                        if (user != null) {
                          Get.offAndToNamed('/home');
                        }
                      },
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    _buildSocialMediaButton(
                      'assets/face.png',
                      'Facebook',
                      height: 80,
                      width: 90,
                      onTap: () {},
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    _buildSocialMediaButton(
                      'assets/twitter.png',
                      'Twitter',
                      height: 40,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextField with Icon
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Reusable Social Media Button with Image and Gradient Background
  Widget _buildSocialMediaButton(
    String imagePath,
    String label, {
    double height = 44,
    double width = 44,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff1f319d),
              Color(0xff1133a6),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            height: height * 0.6,
            width: width * 0.6,
          ),
        ),
      ),
    );
  }
}

// Custom FadeIn Widget
class FadeIn extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const FadeIn({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      builder: (context, double opacity, _) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
    );
  }
}
