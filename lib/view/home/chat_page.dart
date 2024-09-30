import 'package:chat_app/controller/chat_controller.dart';
import 'package:chat_app/modal/chat_modal.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../services/cloud_fire_store_service.dart';
import '../../services/local_notification_service.dart';
import '../../services/storage_services.dart';

var chatController = Get.put(ChatController());

class ChatPage extends StatefulWidget {
  final String? img;

  const ChatPage({super.key, this.img});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // FocusNode focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 35),
        child: Column(
          children: [
            Obx(
              () => (chatController.toggleBar.value)
                  ? _buildEditBar(w)
                  : _buildNormalBar(w),
            ),
            SizedBox(
              height: h * 0.03,
            ),
            Expanded(
              child: StreamBuilder(
                stream: CloudFireStoreService.cloudFireStoreService
                    .readChatFromFireStore(chatController.receiverEmail.value),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
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
                  for (var snap in data) {
                    docIdList.add(snap.id);
                    chatList.add(
                      ChatModal.fromMap(snap.data() as Map<String, dynamic>),
                    );
                  }

                  // Scroll to bottom when new data is loaded
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return SingleChildScrollView(
                    controller: _scrollController, // Attach ScrollController
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ...List.generate(chatList.length, (index) {
                          if (chatList[index].isRead == false &&
                              chatList[index].receiver ==
                                  AuthService.authService
                                      .getCurrentUser()!
                                      .email) {
                            CloudFireStoreService.cloudFireStoreService
                                .updateMessageReadStatus(
                                    chatController.receiverEmail.value,
                                    docIdList[index]);
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8, right: 14, left: 14),
                            child: Container(
                              alignment: (chatList[index].sender ==
                                      AuthService.authService
                                          .getCurrentUser()!
                                          .email!)
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: (chatList[index].sender ==
                                          AuthService.authService
                                              .getCurrentUser()!
                                              .email!)
                                      ? const Color(0xff3572EF)
                                      : const Color(0xffACE2E1),
                                  borderRadius: (chatList[index].sender ==
                                          AuthService.authService
                                              .getCurrentUser()!
                                              .email!)
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(13),
                                          bottomLeft: Radius.circular(13),
                                          bottomRight: Radius.circular(13),
                                        )
                                      : const BorderRadius.only(
                                          topRight: Radius.circular(13),
                                          bottomLeft: Radius.circular(13),
                                          bottomRight: Radius.circular(13),
                                        ),
                                ),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onLongPress: () {
                                        bool isCurrentUser =
                                            chatList[index].sender ==
                                                AuthService.authService
                                                    .getCurrentUser()
                                                    ?.email;
                                        if (isCurrentUser) {
                                          chatController.docId.value =
                                              docIdList[index];
                                          chatController.messageController
                                              .value = chatList[index].message!;
                                          chatController.toggleBar.value = true;
                                        }
                                      },
                                      onTap: () {
                                        if (chatList[index].sender ==
                                            AuthService.authService
                                                .getCurrentUser()!
                                                .email!) {
                                          CloudFireStoreService
                                              .cloudFireStoreService
                                              .removeChat(
                                                  docIdList[index],
                                                  chatController
                                                      .receiverEmail.value);
                                        }
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          chatList[index].image!.isEmpty
                                              ? Text(
                                                  chatList[index].message!,
                                                  style: TextStyle(
                                                    color: chatList[index]
                                                                .sender ==
                                                            AuthService
                                                                .authService
                                                                .getCurrentUser()!
                                                                .email
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                )
                                              : Image.network(
                                                  chatList[index].image!,
                                                  fit: BoxFit.cover,
                                                  height: 200,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                (loadingProgress
                                                                        .expectedTotalBytes ??
                                                                    1)
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Text(
                                                      'Image failed to load',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    );
                                                  },
                                                ),
                                          SizedBox(
                                            height: h * 0.002,
                                            width: w * 0.02,
                                          ),
                                          Text(
                                            chatController.formatTimestamp(
                                                chatList[index].time),
                                            style: TextStyle(
                                              color: chatList[index].sender ==
                                                      AuthService.authService
                                                          .getCurrentUser()!
                                                          .email!
                                                  ? Colors
                                                      .white // Time color for sent messages
                                                  : Colors.grey.shade600,
                                              // Time color for received messages
                                              fontSize: w * 0.0344, // Font size
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          if (chatList[index].isRead &&
                                              chatList[index].sender ==
                                                  AuthService.authService
                                                      .getCurrentUser()!
                                                      .email!)
                                            Icon(
                                              Icons.done_all_rounded,
                                              // Read status icon
                                              color: Colors.blue.shade400,
                                              size: 18,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.attach_file_outlined,
                    color: Color(0xff808684),
                  ),
                ),
                Expanded(
                  child: TextField(
                    // focusNode: focusNode,
                    onChanged: (value) {
                      chatController.txtMessage.text = value;
                      CloudFireStoreService.cloudFireStoreService
                          .changeOnlineStatus(
                        true,
                        Timestamp.now(),
                        true,
                      );
                    },
                    onTapOutside: (event) {
                      CloudFireStoreService.cloudFireStoreService
                          .changeOnlineStatus(
                        true,
                        Timestamp.now(),
                        false,
                      );
                    },
                    cursorColor: Colors.black,
                    controller: chatController.txtMessage,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      hintText: 'Write your message',
                      hintStyle: const TextStyle(
                          color: Color(0xffb5b9ba),
                          fontWeight: FontWeight.w400),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade100,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade100,
                        ),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              String url = await StorageServices.storageServices
                                  .uploadImageToStorage();
                              chatController.uploadImageToStorage(url);
                            },
                            icon: const Icon(Icons.image),
                          ),
                          IconButton(
                            onPressed: () async {
                              String message =
                                  chatController.txtMessage.text.trim();

                              if (chatController.imageStore.value.isNotEmpty) {
                                ChatModal chat = ChatModal(
                                  time: Timestamp.now(),
                                  receiver: chatController.receiverEmail.value,
                                  message: message,
                                  sender: AuthService.authService
                                      .getCurrentUser()!
                                      .email,
                                  image: chatController.imageStore.value,
                                );
                                chatController.txtMessage.clear();
                                chatController.uploadImageToStorage("");
                                await CloudFireStoreService
                                    .cloudFireStoreService
                                    .addChatInFireStore(chat);
                              }

                              if (message.isNotEmpty) {
                                ChatModal chat = ChatModal(
                                  image: '',
                                  sender: AuthService.authService
                                      .getCurrentUser()!
                                      .email!,
                                  receiver: chatController.receiverEmail.value,
                                  message: chatController.txtMessage.text,
                                  time: Timestamp.now(),
                                );
                                await CloudFireStoreService
                                    .cloudFireStoreService
                                    .addChatInFireStore(chat);

                                await LocalNotificationService
                                    .notificationService
                                    .showNotification(
                                        AuthService.authService
                                            .getCurrentUser()!
                                            .email!,
                                        chatController.txtMessage.text);

                                chatController.txtMessage.clear();
                                _scrollToBottom();
                                CloudFireStoreService.cloudFireStoreService
                                    .changeOnlineStatus(
                                  true,
                                  Timestamp.now(),
                                  false,
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Color(0xff3c4a7a),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    CupertinoIcons.camera,
                    color: Color(0xff808684),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    CupertinoIcons.mic,
                    color: Color(0xff808684),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: h * 0.02,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalBar(double width) {
    return Row(
      children: [
        SizedBox(width: width * 0.02),
        CircleAvatar(
          radius: width * 0.070,
          backgroundImage: NetworkImage(chatController.image.value),
        ),
        SizedBox(width: width * 0.033),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatController.receiverName.value,
              style: GoogleFonts.gideonRoman(
                  wordSpacing: 0.5,
                  color: Colors.black,
                  fontSize: 17.5,
                  fontWeight: FontWeight.w600),
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
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.call,
              color: Colors.grey,
            )),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.videocam_outlined,
            size: 28,
            color: Colors.grey,
          ),
        ),
        PopupMenuButton(
          color: Colors.white,
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
          child: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(
              Icons.arrow_back_outlined,
              color: Colors.black,
            ),
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
            chatController.toggleBar.value = false;
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
          color: Colors.white,
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
