import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../models/event.dart';
import 'frienddetail/frddetails.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final CardSwiperController controller = CardSwiperController();
  List<details> users = [];
  bool isLoading = true;
  String errorMessage = '';
  int topCardIndex = 0;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: currentUser.uid)
          .limit(20)
          .get();

      setState(() {
        users = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return details(
            firstname: data['firstName'] ?? '',
            lastname: data['lastName'] ?? '',
            dateofbirth: data['dob'] ?? '',
            gender: data['gender'] ?? '',
            emailid: data['email'] ?? '',
            phoneno: _parseInteger(data['phoneNo']),
            collegename: data['collegeName'] ?? '',
            roolno: _parseInteger(data['rollNumber']),
            branch: data['branch'] ?? '',
            year: data['year'],
            dp: data['dp'] ?? '',
            img1url: data['img1url'] ?? '',
            img2url: data['img2url'] ?? '',
            img3url: data['img3url'] ?? '',
            img4url: data['img4url'] ?? '',
            img5url: data['img5url'] ?? '',
            img6url: data['img6url'] ?? '',
            insta: data['insta'] ?? '',
            linkedin: data['linkedin'] ?? '',
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load users: ${e.toString()}';
      });
    }
  }

  int _parseInteger(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : users.isEmpty
          ? Center(child: Text('No users found'))
          : Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
          ),
          Expanded(
            child: CardSwiper(
              controller: controller,
              cardsCount: users.length,
              numberOfCardsDisplayed: 4,
              backCardOffset: const Offset(10, 20),
              padding: const EdgeInsets.all(24.0),
              cardBuilder: (context, index, _, __) {
                if (index >= 0 && index < users.length) {
                  return _buildCard(users[index]);
                } else {
                  return Container(); // Handle out-of-bounds index
                }
              },
              onSwipe: _onSwipe,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(details user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(user: user),
          ),
        );
      },
      child: Hero(
        tag: user.emailid, // Use a unique tag for the Hero animation
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: user.img1url.isNotEmpty
                    ? Image.network(
                  user.img1url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image_not_supported, size: 100),
                )
                    : Icon(Icons.image_not_supported, size: 100),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${user.firstname} ${user.lastname}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${user.branch} - ${user.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
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

  Future<bool> _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) async {
    print('Previous Index: $previousIndex');
    print('Current Index: $currentIndex');
    print('Swipe Direction: $direction');

    if (currentIndex == null || currentIndex < 0 || currentIndex >= users.length) {
      return false;
    }

    // Update topCardIndex to the currentIndex
    topCardIndex = currentIndex;

    final user = users[topCardIndex]; // Use the topCardIndex for actions
    print('User at topCardIndex: ${user.firstname}');

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    // Prevent sending a friend request to oneself
    if (user.emailid == currentUser.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot send a friend request to yourself')),
      );
      return false;
    }

    if (direction == CardSwiperDirection.right) {
      await _sendFriendRequest(user);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${user.firstname}')),
      );
    } else if (direction == CardSwiperDirection.left) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passed on ${user.firstname}')),
      );
    }

    return true;
  }

  Future<void> _sendFriendRequest(details targetUser) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final friendRequestsRef = FirebaseFirestore.instance.collection('friend_requests');

    await friendRequestsRef.add({
      'sender_id': currentUser.uid,
      'sender_name': '${currentUser.displayName ?? 'Anonymous'}',
      'sender_dp': currentUser.photoURL ?? '',
      'receiver_id': targetUser.emailid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    print('Friend request sent to ${targetUser.firstname} ${targetUser.lastname}');
  }
}
