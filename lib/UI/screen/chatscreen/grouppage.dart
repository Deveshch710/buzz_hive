import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:buzz_hive/Constants.dart'; // Import Constants for consistent design

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _selectedMembers = [];
  File? _groupImage;
  String _searchText = '';

  Future<void> _pickGroupImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _groupImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.isNotEmpty && _groupImage != null && _selectedMembers.isNotEmpty) {
      final groupId = _firestore.collection('groups').doc().id;

      final storageRef = FirebaseStorage.instance.ref().child('group_images/$groupId.jpg');
      final uploadTask = await storageRef.putFile(_groupImage!);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      final currentUserEmail = _auth.currentUser!.email!;
      if (!_selectedMembers.contains(currentUserEmail)) {
        _selectedMembers.add(currentUserEmail);
      }

      await _firestore.collection('groups').doc(groupId).set({
        'groupName': _groupNameController.text,
        'groupImage': imageUrl,
        'members': _selectedMembers,
        'admin': currentUserEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent automatic resizing
      backgroundColor: Constants.back,
      appBar: AppBar(
        title: Text('Create Group'),
        backgroundColor: Constants.primarycolor,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickGroupImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _groupImage != null ? FileImage(_groupImage!) : null,
                      child: _groupImage == null ? Icon(Icons.camera_alt, color: Colors.white) : null,
                      backgroundColor: Constants.secondarycolor.withOpacity(1),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.secondarycolor),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.primarycolor, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),

                  // Add members
                  SizedBox(height: 40.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Add members',
                        style: TextStyle(
                          color: Constants.secondarycolor,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        width: MediaQuery.of(context).size.width * .4,
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
                                  hintText: 'Search',
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

                  // Container having all the people
                  SizedBox(height: 15.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.secondarycolor, width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final users = snapshot.data!.docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();

                        // Filter users based on the search query
                        final filteredUsers = users.where((user) {
                          final firstName = user['firstName'].toLowerCase();
                          final lastName = user['lastName'].toLowerCase();
                          final searchQuery = _searchText.toLowerCase();
                          return firstName.contains(searchQuery) || lastName.contains(searchQuery);
                        }).toList();

                        return ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final email = user['email'];
                            final name = '${user['firstName']} ${user['lastName']}';
                            final dpUrl = user.containsKey('dp') ? user['dp'] : '';

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 1.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: dpUrl.isNotEmpty ? NetworkImage(dpUrl) : null,
                                  child: dpUrl.isEmpty ? Icon(Icons.person) : null,
                                ),
                                title: Text(name),
                                trailing: Checkbox(
                                  value: _selectedMembers.contains(email),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedMembers.add(email);
                                      } else {
                                        _selectedMembers.remove(email);
                                      }
                                    });
                                  },
                                  activeColor: Constants.secondarycolor,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: _createGroup,
              child: Text('Create Community'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primarycolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                minimumSize: Size(double.infinity, 50), // Make the button full-width and taller
              ),
            ),
          ),
        ],
      ),
    );
  }
}
