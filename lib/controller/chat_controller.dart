import 'package:chat_app/services/cloud_fire_store_service.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  RxString receiverEmail = "".obs;
  RxString receiverName = "".obs;
  TextEditingController txtMessage = TextEditingController();
  TextEditingController txtUpdateMessage= TextEditingController();
  RxBool toggleBar = false.obs;
  RxString image = ''.obs;
  RxString docId = ''.obs;
  RxString messageController = ''.obs;
  RxBool isEditing = false.obs;
  RxString messageIdToEdit = ''.obs;

  void gerReceiver(String email, String name) {
    receiverName.value = name;
    receiverEmail.value = email;
  }

  void toggleAppBar(bool value){
    toggleBar.value = value;
  }

  // to copy the message
  void copyMessage(String message) {
    FlutterClipboard.copy(message);
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String amPm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // Convert 0 to 12 for 12-hour format

    String minuteStr = minute < 10 ? '0$minute' : minute.toString(); // Add leading zero if needed
    return '$hour:$minuteStr $amPm';
  }

  void showEditDeleteDialog(String messageId, String message,
      String receiverEmail, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete',
          ),
          content: const Text('Do you want to delete this message?'),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                // Delete the message from Firestore
                CloudFireStoreService.cloudFireStoreService.removeChat(
                  messageId,
                  receiverEmail,
                );
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
