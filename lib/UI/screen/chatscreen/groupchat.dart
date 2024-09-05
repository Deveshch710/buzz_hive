import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;

  GroupChatPage({required this.groupId});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead(); // Mark messages as read when the page opens
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final user = _auth.currentUser!;
      final groupRef = _firestore.collection('groups').doc(widget.groupId);

      // Add the message to the 'messages' collection
      await _firestore.collection('groups').doc(widget.groupId).collection('messages').add({
        'text': _messageController.text,
        'sender': user.email,
        'senderName': user.displayName ?? 'Anonymous',
        'senderDp': user.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Fetch group members
      final groupSnapshot = await groupRef.get();
      final groupData = groupSnapshot.data() as Map<String, dynamic>;
      final members = List<String>.from(groupData['members'] ?? []);

      // Update the group with the latest message timestamp and unreadBy field
      await groupRef.update({
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadBy': FieldValue.arrayUnion(members.where((member) => member != user.email).toList()),
      });

      _messageController.clear();
    }
  }


  void _markMessagesAsRead() async {
    final currentUserEmail = _auth.currentUser!.email;

    // Remove the current user's email from the unreadBy array
    await _firestore.collection('groups').doc(widget.groupId).update({
      'unreadBy': FieldValue.arrayRemove([currentUserEmail])
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('groups').doc(widget.groupId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('Loading...');
            }
            final groupData = snapshot.data!.data() as Map<String, dynamic>;
            return Text(groupData['groupName']);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    return _buildMessageTile(message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> message) {
    final bool isMe = message['sender'] == _auth.currentUser!.email;
    return ListTile(
      leading: isMe
          ? null
          : CircleAvatar(
        backgroundImage: message['senderDp'] != ''
            ? NetworkImage(message['senderDp'])
            : null,
        child: message['senderDp'] == '' ? Icon(Icons.person) : null,
      ),
      title: Text(message['senderName']),
      subtitle: Text(message['text']),
      trailing: isMe
          ? CircleAvatar(
        backgroundImage: message['senderDp'] != ''
            ? NetworkImage(message['senderDp'])
            : null,
        child: message['senderDp'] == '' ? Icon(Icons.person) : null,
      )
          : null,
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
