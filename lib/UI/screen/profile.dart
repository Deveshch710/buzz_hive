import 'package:buzz_hive/UI/screen/profilescreen/resetpass.dart';
import 'package:buzz_hive/UI/screen/profilescreen/personalinformation.dart';
import 'package:buzz_hive/UI/screen/profilescreen/photoupdate.dart';
import 'package:buzz_hive/UI/screen/profilescreen/chatseeting.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Constants.dart';
import 'login.dart';

class profilepage extends StatelessWidget {
  const profilepage({super.key});

  Stream<Map<String, dynamic>?> _fetchUserDetails() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      yield* FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) => snapshot.data());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Constants.back,
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _fetchUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Error fetching user data or no data found'));
          }

          final userData = snapshot.data!;
          String dpUrl = userData['dp'] ?? 'assets/images/profile.jpg';
          String firstName = userData['firstName'] ?? 'Unknown';
          String lastName = userData['lastName'] ?? 'User';
          String email = userData['email'] ?? 'No email provided';

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              height: size.height,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(dpUrl),
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Constants.primarycolor.withOpacity(.5),
                        width: 5.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$firstName $lastName',
                          style: TextStyle(
                            color: Constants.blackColor,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    email,
                    style: TextStyle(
                      color: Constants.blackColor.withOpacity(.3),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: size.height * .4,
                    width: size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProfileWidget(
                          icon: Icons.person,
                          title: 'Personal Information',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PersonalInfoPage()),
                          ),
                        ),
                        ProfileWidget(
                          icon: Icons.image_sharp,
                          title: 'Photos',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UpdatePhotosPage()),
                          ),
                        ),
                        ProfileWidget(
                          icon: Icons.password,
                          title: 'Change Password',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                          ),
                        ),
                        ProfileWidget(
                          icon: Icons.mark_chat_unread,
                          title: 'Chat Setting',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SharePage()),
                          ),
                        ),
                        ProfileWidget(
                          icon: Icons.settings_accessibility,
                          title: 'Friends Setting',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SharePage()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Logout button
                  InkWell(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const login()),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Successfully logged out.'),
                                    ),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.message ?? 'Sign out failed.'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('An unexpected error occurred.'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Log Out'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Constants.primarycolor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: const Center(
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
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


//buttons class
class ProfileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap; // Add the onTap parameter

  const ProfileWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap, // Initialize the onTap parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
      onTap: onTap, // Assign the onTap callback to ListTile's onTap
    );
  }
}

