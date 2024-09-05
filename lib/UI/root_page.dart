import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:buzz_hive/UI/screen/chat.dart';
import 'package:buzz_hive/UI/screen/friends.dart';
import 'package:buzz_hive/UI/screen/homescreen.dart';
import 'package:buzz_hive/UI/screen/notification/notificationbadge.dart';
import 'package:buzz_hive/UI/screen/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  bool _isPanelVisible = false; // <-- Add this line

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
      _firestore.collection('friend_requests').doc(user.uid).collection('requests')
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          if (doc['status'] == 'pending') {
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.secondarycolor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ['Home', 'Connect', 'Chat', 'Profile'][_bottomNavIndex],
              style: TextStyle(
                color: Constants.primarycolor,
                fontWeight: FontWeight.w800,
                fontSize: 30,
              ),
            ),
            IconButton(
              icon: Icon(Icons.notifications, color: Constants.primarycolor),
              onPressed: () {
                setState(() {
                  _isPanelVisible = !_isPanelVisible;
                });
              },
            ),
          ],
        ),
        elevation: .0,
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
          if (_isPanelVisible)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: FriendRequestPanel(
                onClose: () {
                  setState(() {
                    _isPanelVisible = false;
                  });
                },
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
