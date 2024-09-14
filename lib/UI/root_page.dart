import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:buzz_hive/UI/screen/chat.dart';
import 'package:buzz_hive/UI/screen/friends.dart';
import 'package:buzz_hive/UI/screen/homescreen.dart';
import 'package:buzz_hive/UI/screen/notification/notificationbadge.dart';
import 'package:buzz_hive/UI/screen/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../Constants.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _bottomNavIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool _isPanelVisible = false;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenForFriendRequests();
  }

  Future<void> _initializeNotifications() async {
    const initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _listenForFriendRequests() async {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('friend_requests')
          .doc(user.uid)
          .collection('requests')
          .snapshots()
          .listen((snapshot) {
        int newNotifications = 0;
        for (final doc in snapshot.docs) {
          if (doc['status'] == 'pending') {
            newNotifications++;
            _flutterLocalNotificationsPlugin.show(
              0,
              'Friend Request',
              'You have a new friend request!',
              NotificationDetails(
                android: AndroidNotificationDetails(
                  'your_channel_id',
                  'your_channel_name',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
            );
          }
        }
        setState(() {
          _notificationCount = newNotifications;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.secondarycolor,
        title: Text(
          ['Home', 'Connect', 'Chat', 'Profile'][_bottomNavIndex],
          style: TextStyle(
            color: Constants.primarycolor,
            fontWeight: FontWeight.w800,
            fontSize: 30,
          ),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications, color: Constants.primarycolor),
                if (_notificationCount > 0)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$_notificationCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              setState(() {
                _isPanelVisible = !_isPanelVisible;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _bottomNavIndex,
            children: [
              const homepage(),
              const FriendPage(),
              const UserListPage(),
              const profilepage(),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              opacity: _isPanelVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: FriendRequestPanel(
                  onClose: () {
                    setState(() {
                      _isPanelVisible = true;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: Constants.secondarycolor,
        splashColor: Constants.secondarycolor,
        activeColor: Constants.back,
        inactiveColor: Constants.primarycolor,
        icons: [
          Icons.home,
          Icons.person_add_alt_1,
          Icons.chat,
          Icons.settings,
        ],
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.none,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }
}
