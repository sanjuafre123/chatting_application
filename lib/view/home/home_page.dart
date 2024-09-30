import 'package:chat_app/controller/chat_controller.dart';
import 'package:chat_app/modal/user_model.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/cloud_fire_store_service.dart';
import 'package:chat_app/view/home/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

var chatController = Get.put(ChatController());

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CloudFireStoreService.cloudFireStoreService.changeOnlineStatus(
      true,
      Timestamp.now(),
      false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      CloudFireStoreService.cloudFireStoreService.changeOnlineStatus(
        false,
        Timestamp.now(),
        false,
      );
    } else if (state == AppLifecycleState.resumed) {
      CloudFireStoreService.cloudFireStoreService.changeOnlineStatus(
        true,
        Timestamp.now(),
        false,
      );
    } else if (state == AppLifecycleState.inactive) {
      CloudFireStoreService.cloudFireStoreService.changeOnlineStatus(
        false,
        Timestamp.now(),
        false,
      );
    } else if (state == AppLifecycleState.detached) {
      CloudFireStoreService.cloudFireStoreService.changeOnlineStatus(
        false,
        Timestamp.now(),
        false,
      );
    } else if (state == AppLifecycleState.hidden) {
      CloudFireStoreService.cloudFireStoreService.changeOnlineStatus(
        false,
        Timestamp.now(),
        false,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      // drawer: Drawer(
      //   width: 265,
      //   child: Container(
      //     color: const Color(0xFFF4F4F4), // Light grey background for drawer
      //     child: FutureBuilder(
      //       future: CloudFireStoreService.cloudFireStoreService
      //           .readCurrentUserFromFireStore(),
      //       builder: (BuildContext context,
      //           AsyncSnapshot<DocumentSnapshot> snapshot) {
      //         if (snapshot.hasError) {
      //           return Center(
      //             child: Text(snapshot.error.toString()),
      //           );
      //         }
      //         if (snapshot.connectionState == ConnectionState.waiting) {
      //           return const Center(
      //             child: CircularProgressIndicator(),
      //           );
      //         }
      //         if (snapshot.hasData && snapshot.data != null) {
      //           Map? data = snapshot.data!.data() as Map?;
      //           if (data != null) {
      //             UserModel userModel = UserModel.fromMap(data);
      //             return Column(
      //               children: [
      //                 Row(
      //                   children: [
      //                     DrawerHeader(
      //                       child: CircleAvatar(
      //                         radius: 35,
      //                         backgroundImage: NetworkImage(userModel.image!),
      //                       ),
      //                     ),
      //                     Padding(
      //                       padding: const EdgeInsets.only(top: 30),
      //                       child: Text(
      //                         userModel.name!,
      //                         style: const TextStyle(
      //                           fontSize: 20,
      //                           fontWeight: FontWeight.w600,
      //                           color: Color(0xFF2D2D2D), // Dark text color
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(height: 15),
      //                 const Padding(
      //                   padding: EdgeInsets.only(left: 13, top: 8),
      //                   child: Column(
      //                     children: [
      //                       Row(
      //                         children: [
      //                           Icon(Icons.key, color: Color(0xFF2D2D2D)),
      //                           // Dark icon color
      //                           SizedBox(width: 30),
      //                           Text(
      //                             'Account',
      //                             style: TextStyle(
      //                                 fontSize: 17, color: Color(0xFF2D2D2D)),
      //                           ),
      //                         ],
      //                       ),
      //                       SizedBox(height: 35),
      //                       Row(
      //                         children: [
      //                           Icon(Icons.messenger_outlined,
      //                               size: 22, color: Color(0xFF2D2D2D)),
      //                           SizedBox(width: 30),
      //                           Text('Chats',
      //                               style: TextStyle(
      //                                   fontSize: 17,
      //                                   color: Color(0xFF2D2D2D))),
      //                         ],
      //                       ),
      //                       SizedBox(height: 35),
      //                       Row(
      //                         children: [
      //                           Icon(Icons.notifications,
      //                               color: Color(0xFF2D2D2D)),
      //                           SizedBox(width: 30),
      //                           Text('Notification',
      //                               style: TextStyle(
      //                                   fontSize: 17,
      //                                   color: Color(0xFF2D2D2D))),
      //                         ],
      //                       ),
      //                       SizedBox(height: 35),
      //                       Row(
      //                         children: [
      //                           Icon(Icons.group, color: Color(0xFF2D2D2D)),
      //                           SizedBox(width: 30),
      //                           Text('Invite & Friends',
      //                               style: TextStyle(
      //                                   fontSize: 17,
      //                                   color: Color(0xFF2D2D2D))),
      //                         ],
      //                       ),
      //                       SizedBox(height: 35),
      //                       Row(
      //                         children: [
      //                           Icon(Icons.light_mode_rounded,
      //                               color: Color(0xFF2D2D2D)),
      //                           SizedBox(width: 30),
      //                           Text('Theme mode',
      //                               style: TextStyle(
      //                                   fontSize: 17,
      //                                   color: Color(0xFF2D2D2D))),
      //                         ],
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //                 const Spacer(),
      //                 Padding(
      //                   padding: const EdgeInsets.only(
      //                       left: 15, right: 15, bottom: 28),
      //                   child: Row(
      //                     children: [
      //                       GestureDetector(
      //                         onTap: () async {
      //                           await CloudFireStoreService.cloudFireStoreService
      //                               .changeOnlineStatus(
      //                             false,
      //                             Timestamp.now(),
      //                             false,
      //                           );
      //                           await AuthService.authService.signOutUser();
      //                           await GoogleAuthService.googleAuthService
      //                               .signOutFromGoogle();
      //                           User? user =
      //                               AuthService.authService.getCurrentUser();
      //                           if (user == null) {
      //                             Get.offAndToNamed('/signIn');
      //                           }
      //                         },
      //                         child: const Icon(Icons.logout,
      //                             color: Color(0xFFD32F2F)), // Logout in red
      //                       ),
      //                       const SizedBox(width: 30),
      //                       const Text(
      //                         'Log Out',
      //                         style: TextStyle(
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w500,
      //                           color:
      //                               Color(0xFFD32F2F), // Text in red for logout
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 )
      //               ],
      //             );
      //           } else {
      //             return const Center(
      //               child: Text('No user data found'),
      //             );
      //           }
      //         } else {
      //           return const Center(
      //             child: Text('No data available'),
      //           );
      //         }
      //       },
      //     ),
      //   ),
      // ),
      // appBar: AppBar(
      //   title: const Text('Home Page'),
      //   backgroundColor:
      //       const Color(0xFF1976D2), // Primary blue color for app bar
      // ),
      // body: FutureBuilder(
      //   future: CloudFireStoreService.cloudFireStoreService
      //       .readAllUserFromCloudFireStore(),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasError) {
      //       return Center(
      //         child: Text(snapshot.error.toString()),
      //       );
      //     }
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //     List data = snapshot.data!.docs;
      //     List<UserModel> usersList = [];
      //
      //     for (var user in data) {
      //       usersList.add(UserModel.fromMap(user.data()));
      //     }
      //
      //     return ListView.builder(
      //       itemCount: usersList.length,
      //       itemBuilder: (context, index) {
      //         return ListTile(
      //           onTap: () {
      //             chatController.gerReceiver(
      //                 usersList[index].email!, usersList[index].name!);
      //             chatController.image.value = usersList[index].image!;
      //             Get.toNamed('/chat');
      //           },
      //           leading: CircleAvatar(
      //             backgroundImage: NetworkImage(usersList[index].image!),
      //           ),
      //           title: Text(usersList[index].name!),
      //           subtitle: Text(usersList[index].email!),
      //         );
      //       },
      //     );
      //   },
      // ),
      body: FutureBuilder(
        future: CloudFireStoreService.cloudFireStoreService
            .readAllUserFromCloudFireStore(),
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
          List<UserModel> userList = [];
          for (var user in data) {
            userList.add(UserModel.fromMap(user.data()));
          }
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(seconds: 15),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2d429b),
                      Color(0xff248fc3),
                      Color(0xff1ddaed),
                      Color(0xff1cf5fa),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: h * 0.04,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12,bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 25,
                        ),
                        Text('Chats',style: TextStyle(color: Colors.white,fontSize: 22),),
                        CircleAvatar(
                          radius: h * 0.023,
                          backgroundImage: AuthService.authService
                                      .getCurrentUser()
                                      ?.photoURL !=
                                  null
                              ? NetworkImage(AuthService.authService
                                  .getCurrentUser()!
                                  .photoURL!)
                              : const NetworkImage(
                                  'https://www.pngkit.com/png/detail/25-258694_cool-avatar-transparent-image-cool-boy-avatar.png'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: h * 0.007,
                  ),
                  SizedBox(
                    height: h * 0.12,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: w * 0.086,
                                backgroundImage:
                                    NetworkImage(userList[index].image!),
                              ),
                              SizedBox(height: h * 0.01),
                              SizedBox(
                                width: w * 0.18,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  userList[index].name!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: w * 0.034, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black,width: 0.5),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(w * 0.10),
                          topRight: Radius.circular(w * 0.10),
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            onTap: () {
                              chatController.gerReceiver(
                                userList[index].email!,
                                userList[index].name!,
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatPage(img: userList[index].image),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              radius: w * 0.066,
                              backgroundImage:
                                  NetworkImage(userList[index].image!),
                            ),
                            title: Text(userList[index].name!),
                            trailing: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Colors.red,
                                  child: Center(
                                    child: Text(
                                      '3',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '5:45 PM',
                                  style: TextStyle(
                                      color: Color(0xffbcbebd),
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const HomeBottomNavigation(),
    );
  }
}

class HomeBottomNavigation extends StatefulWidget {
  const HomeBottomNavigation({super.key});

  @override
  _HomeBottomNavigationState createState() => _HomeBottomNavigationState();
}

class _HomeBottomNavigationState extends State<HomeBottomNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (_selectedIndex == 3) {
        Get.toNamed('/set')?.then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      unselectedItemColor: Colors.grey.shade400,
      selectedItemColor: const Color(0xff3e4a7a),
      selectedIconTheme: const IconThemeData(
        color: Color(0xff3e4a7a),
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.grey.shade400,
      ),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(
            Icons.message,
          ),
          label: 'Message',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.call),
          label: 'Calls',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.contacts),
          label: 'Contacts',
        ),
        BottomNavigationBarItem(
          icon: InkWell(
              onTap: () {
                Get.offAndToNamed('/profile');
              },
              child: Icon(Icons.settings)),
          label: 'Settings',
        ),
      ],
    );
  }
}
