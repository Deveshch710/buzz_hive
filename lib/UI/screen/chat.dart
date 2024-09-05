import 'package:buzz_hive/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chatscreen/chatpage.dart';
import 'chatscreen/groupchat.dart';
import 'chatscreen/grouppage.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Ensure this is initialized
  late final String currentUserEmail; // Use late to initialize in initState
  int _selectedIndex = 0; // To track selected tab (0: Users, 1: Community)
  String _searchText = ''; // To store user search query

  @override
  void initState() {
    super.initState();
    // Initialize currentUserEmail in initState
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      currentUserEmail = currentUser.email!;
    } else {
      // Handle case where user is not signed in
      currentUserEmail = '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs for Users and Community
      child: Scaffold(
        body: Container(
          color: Constants.back, // Set background color
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.orange, // Adjust label color for visibility (optional)
                unselectedLabelColor: Colors.black, // Adjust unselected label color (optional)
                indicatorColor: Colors.black, // Adjust indicator color (optional)
                tabs: [
                  Tab(text: 'Chat'),
                  Tab(text: 'Community'),
                ],
                onTap: (index) => setState(() => _selectedIndex = index),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.orange, width: 3.0), // Customize tab indicator (optional)
                ),
                dividerColor: Colors.black,
                dividerHeight: 1.5,
              ),
              Expanded( // Ensures TabBarView fills remaining space
                child: TabBarView(
                  children: [
                    // Users list
                    _buildUserListTab(), // Call function to build user list tab

                    // Community content
                    _buildCommunityContentTab(), // Call function to build community content tab
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserListTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width * .9,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.black54.withOpacity(.6),
                    ),
                    Expanded(
                      child: TextField(
                        showCursor: true,
                        decoration: InputDecoration(
                          hintText: 'Search Chat',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() => _searchText = value);
                        },
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Constants.primarycolor.withOpacity(.3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  final email = user['email'];
                  final firstName = user['firstName'];
                  final lastName = user['lastName'];
                  final dpUrl = user.containsKey('dp') ? user['dp'] : '';

                  // Skip the current user
                  if (email == currentUserEmail) {
                    return SizedBox.shrink();
                  }

                  // Get unread counts for this user
                  final unreadCounts = user['unreadCounts'] as Map<String, dynamic>? ?? {};
                  final unreadCount = unreadCounts[currentUserEmail] ?? 0;
                  final hasUnreadMessages = unreadCount > 0;

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPageWithUser(userEmail: email),
                        ),
                      );

                      // Update unread count after opening the chat
                      await _firestore.collection('chats').doc(_generateChatRoomId(email)).update({
                        '$currentUserEmail.unreadCounts': FieldValue.delete(), // Clear unread counts
                        '$currentUserEmail.lastSeen': FieldValue.serverTimestamp(),
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Constants.primarycolor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      child: Stack(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: dpUrl.isNotEmpty
                                  ? NetworkImage(dpUrl)
                                  : AssetImage('assets/images/placeholder.png') as ImageProvider,
                            ),
                            title: Text('$firstName $lastName'),
                          ),
                          Positioned(
                            right: 10,
                            top: 30,
                            child: Visibility(
                              visible: hasUnreadMessages,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _generateChatRoomId(String email) {
    return currentUserEmail.hashCode <= email.hashCode
        ? '$currentUserEmail-$email'
        : '$email-$currentUserEmail';
  }




  Widget _buildCommunityContentTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 8, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                width: MediaQuery.of(context).size.width * .8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.black54.withOpacity(.6),
                    ),
                    Expanded(
                      child: TextField(
                        showCursor: true,
                        decoration: InputDecoration(
                          hintText: 'Search Community',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() => _searchText = value);
                        },
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Constants.primarycolor.withOpacity(.3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              IconButton(
                icon: Icon(Icons.group_add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateGroupPage()),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('groups').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final groups = snapshot.data!.docs;

              // Filter groups based on membership
              final filteredGroups = groups.where((groupDoc) {
                final group = groupDoc.data() as Map<String, dynamic>;
                final members = List<String>.from(group['members'] ?? []);
                return members.contains(currentUserEmail);
              }).toList();

              // Further filter based on search text
              final searchFilteredGroups = filteredGroups.where((groupDoc) {
                final group = groupDoc.data() as Map<String, dynamic>;
                final groupName = group['groupName'] ?? '';
                return groupName.toLowerCase().contains(_searchText.toLowerCase());
              }).toList();

              // Sort groups
              searchFilteredGroups.sort((a, b) {
                final groupA = a.data() as Map<String, dynamic>;
                final groupB = b.data() as Map<String, dynamic>;

                final lastMessageA = groupA['lastMessageTimestamp'] as Timestamp?;
                final lastMessageB = groupB['lastMessageTimestamp'] as Timestamp?;
                final unreadByA = List<String>.from(groupA['unreadBy'] ?? []);
                final unreadByB = List<String>.from(groupB['unreadBy'] ?? []);

                final isSenderA = groupA['members'].contains(currentUserEmail);
                final isSenderB = groupB['members'].contains(currentUserEmail);

                if (unreadByA.contains(currentUserEmail) && !unreadByB.contains(currentUserEmail)) {
                  return -1; // A should come before B
                } else if (!unreadByA.contains(currentUserEmail) && unreadByB.contains(currentUserEmail)) {
                  return 1; // B should come before A
                } else if (isSenderA && !isSenderB) {
                  return -1; // A should come before B if A is sent by the user
                } else if (!isSenderA && isSenderB) {
                  return 1; // B should come before A if B is sent by the user
                } else {
                  // Sort by the last message timestamp
                  return (lastMessageB?.toDate() ?? DateTime.now()).compareTo(lastMessageA?.toDate() ?? DateTime.now());
                }
              });

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: searchFilteredGroups.length,
                itemBuilder: (context, index) {
                  final group = searchFilteredGroups[index].data() as Map<String, dynamic>;
                  final groupName = group['groupName'];
                  final groupImage = group['groupImage'];
                  final hasNewMessages = group['unreadBy']?.contains(currentUserEmail) ?? false;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: Card(
                      color: Constants.primarycolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: groupImage != null ? NetworkImage(groupImage) : null,
                          child: groupImage == null ? const Icon(Icons.group) : null,
                        ),
                        title: Text(
                          groupName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: hasNewMessages
                            ? Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                              color: Constants.thirdcolor, // Red indicator for new messages
                              shape: BoxShape.circle,
                                ),
                              ),
                            )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupChatPage(groupId: searchFilteredGroups[index].id),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

}
