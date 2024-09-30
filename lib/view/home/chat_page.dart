import 'package:chat_app/modal/chat_modal.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/cloud_fire_store_service.dart';
import 'package:chat_app/services/local_notification_service.dart';
import 'package:chat_app/view/home/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   title: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(chatController.receiverName.value),
      //       StreamBuilder(
      //         stream: CloudFireStoreService.cloudFireStoreService
      //             .findUserIsOnlineNot(chatController.receiverEmail.value),
      //         builder: (context, snapshot) {
      //           if (snapshot.hasError) {
      //             return Text('Failed! ${snapshot.error}');
      //           }
      //
      //           if (snapshot.connectionState == ConnectionState.waiting) {
      //             return const Text('');
      //           }
      //
      //           Map? user = snapshot.data!.data();
      //           String nightDay = '';
      //           if (user!['timestamp'].toDate().hour > 11) {
      //             nightDay = 'PM';
      //           } else {
      //             nightDay = 'AM';
      //           }
      //
      //           return Text(
      //             user['isOnline']
      //                 ? (user['isTyping'])
      //                     ? 'Typing...'
      //                     : 'Online'
      //                 : 'Last seen at ${user['timestamp'].toDate().hour % 12}:${user['timestamp'].toDate().minute} $nightDay}',
      //             style: const TextStyle(
      //               fontSize: 11,
      //             ),
      //           );
      //         },
      //       )
      //     ],
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8,top: 25),
        child: Column(
          children: [
            Obx(
              () => (chatController.toggleBar.value)
                  ? _buildEditBar(width)
                  : _buildNormalBar(width),
            ),
            Expanded(
              child: StreamBuilder(
                stream: CloudFireStoreService.cloudFireStoreService
                    .readChatFromFireStore(chatController.receiverEmail.value),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List data = snapshot.data!.docs;
                  List<ChatModal> chatList = [];
                  List<String> docIdList = [];
                  for (QueryDocumentSnapshot snap in data) {
                    docIdList.add(snap.id);
                    chatList.add(
                      ChatModal.fromMap(snap.data() as Map),
                    );
                  }

                  return ListView.builder(
                    itemCount: chatList.length,
                    itemBuilder: (context, index) => GestureDetector(
                      // onLongPress: () {
                      //   if (chatList[index].sender !=
                      //       AuthService.authService.getCurrentUser()!.email!) {
                      //     chatController.txtUpdateMessage =
                      //         TextEditingController(
                      //             text: chatList[index].message);
                      //     showDialog(
                      //       context: context,
                      //       builder: (context) {
                      //         return AlertDialog(
                      //           title: const Text('update'),
                      //           content: TextField(
                      //             controller: chatController.txtUpdateMessage,
                      //           ),
                      //           actions: [
                      //             TextButton(
                      //                 onPressed: () {
                      //                   String docId = docIdList[index];
                      //                   CloudFireStoreService
                      //                       .cloudFireStoreService
                      //                       .updateChat(
                      //                           chatController
                      //                               .receiverEmail.value,
                      //                           chatController
                      //                               .txtUpdateMessage.text,
                      //                           docId);
                      //                   Get.back();
                      //                 },
                      //                 child: const Text('update'))
                      //           ],
                      //         );
                      //       },
                      //     );
                      //   }
                      // },
                      onLongPress: () {
                        bool isCurrentUser = chatList[index].sender ==
                            AuthService.authService.getCurrentUser()?.email;
                        if (isCurrentUser) {
                          chatController.docId.value = docIdList[index];
                          chatController.messageController.value =
                              chatList[index].message!;
                          chatController.toggleBar.value = true;
                        }
                      },
                      onTap: () {
                        if (chatList[index].sender ==
                            AuthService.authService.getCurrentUser()!.email!) {
                          CloudFireStoreService.cloudFireStoreService
                              .removeChat(docIdList[index],
                                  chatController.receiverEmail.value);
                        }
                      },
                      child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          alignment: (chatList[index].sender ==
                                  AuthService.authService
                                      .getCurrentUser()!
                                      .email!)
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(chatList[index].message!)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: chatController.txtMessage,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () async {
                    ChatModal chat = ChatModal(
                      sender: AuthService.authService.getCurrentUser()!.email,
                      receiver: chatController.receiverEmail.value,
                      message: chatController.txtMessage.text,
                      time: Timestamp.now(),
                    );
                    await CloudFireStoreService.cloudFireStoreService
                        .addChatInFireStore(chat);
                    await LocalNotificationService.notificationService
                        .showNotification(
                      AuthService.authService.getCurrentUser()!.email!,
                      chatController.txtMessage.text,
                    );
                    chatController.txtMessage.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNormalBar(double width) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Get.offAndToNamed('/home');
          },
          child: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.black,
          ),
        ),
        SizedBox(width: width * 0.02),
        CircleAvatar(
          radius: 17,
          backgroundImage: NetworkImage(chatController.image.value),
        ),
        SizedBox(width: width * 0.02),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatController.receiverName.value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 19,
              ),
            ),
            StreamBuilder(
              stream: CloudFireStoreService.cloudFireStoreService
                  .findUserIsOnlineNot(chatController.receiverEmail.value),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('');
                }

                Map? user = snapshot.data!.data();
                String nightDay = '';
                if (user!['timestamp'].toDate().hour > 11) {
                  nightDay = 'PM';
                } else {
                  nightDay = 'AM';
                }

                return Text(
                  user['isOnline']
                      ? (user['isTyping'])
                          ? 'Typing...'
                          : 'Online'
                      : 'Last seen at ${user['timestamp'].toDate().hour % 12}:${user['timestamp'].toDate().minute} $nightDay',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ],
        ),
        const Spacer(),
        // _buildCallAndVideoButtons(),
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'View Account',
              child: Text('View Account'),
            ),
            const PopupMenuItem(
              value: 'Media, links, and docs',
              child: Text('Media, links, and docs'),
            ),
            const PopupMenuItem(
              value: 'Report',
              child: Text('Report'),
            ),
            const PopupMenuItem(
              value: 'Block',
              child: Text('Block'),
            ),
            const PopupMenuItem(
              value: 'Wallpaper',
              child: Text('Wallpaper'),
            ),
            const PopupMenuItem(
              value: 'Clear chat',
              child: Text('Clear chat'),
            ),
          ],
          icon: const Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildEditBar(double width) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            chatController.toggleBar.value = false;
          },
          child: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            chatController.showEditDeleteDialog(
              chatController.docId.value,
              chatController.messageController.value,
              chatController.receiverEmail.value,
              context,
            );
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.black,
          ),
        ),
        IconButton(
          onPressed: () {
            chatController.copyMessage(chatController.messageController.value);
            chatController.toggleBar.value = false;
          },
          icon: const Icon(
            Icons.copy,
            color: Colors.black,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            CupertinoIcons.arrow_turn_up_right,
            color: Colors.black,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'Info':
                break;
              case 'Copy':
                break;
              case 'Edit':
                chatController.txtMessage.text =
                    chatController.messageController.value;
                chatController.isEditing.value = true;
                chatController.messageController.value =
                    chatController.docId.value;
                chatController.toggleBar.value = false;

                break;
              case 'Pin':
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'Info',
              child: Text('Info'),
            ),
            const PopupMenuItem(
              value: 'Copy',
              child: Text('Copy'),
            ),
            const PopupMenuItem(
              value: 'Edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'Pin',
              child: Text('Pin'),
            ),
          ],
          icon: const Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
