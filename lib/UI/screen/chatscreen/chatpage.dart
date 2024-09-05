import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPageWithUser extends StatefulWidget {
  final String userEmail;
  const ChatPageWithUser({Key? key, required this.userEmail}) : super(key: key);

  @override
  _ChatPageWithUserState createState() => _ChatPageWithUserState();
}

class _ChatPageWithUserState extends State<ChatPageWithUser> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _chatRoomId = '';
  bool _isEmojiVisible = false;

  @override
  void initState() {
    super.initState();
    _createChatRoomId();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final currentUserEmail = _auth.currentUser!.email!;
      final recipientEmail = widget.userEmail;
      final message = {
        'text': _messageController.text,
        'senderId': currentUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
      };

      _firestore.collection('chats').doc(_chatRoomId).collection('messages').add(message);

      // Update lastSeen for the sender
      _firestore.collection('chats').doc(_chatRoomId).update({
        '$currentUserEmail.lastSeen': FieldValue.serverTimestamp(),
      });

      // Increment unreadCount for the recipient
      _firestore.collection('chats').doc(_chatRoomId).update({
        '$recipientEmail.unreadCounts.$currentUserEmail': FieldValue.increment(1),
      });

      _messageController.clear();
    } else {
      print('Message is empty');
    }
  }



  void _createChatRoomId() {
    final currentUserEmail = _auth.currentUser!.email!;
    _chatRoomId = currentUserEmail.hashCode <= widget.userEmail.hashCode
        ? '$currentUserEmail-${widget.userEmail}'
        : '${widget.userEmail}-$currentUserEmail';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.userEmail}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('chats').doc(_chatRoomId).collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == _auth.currentUser!.email;
                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isEmojiVisible)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  setState(() {
                    _messageController.text += emoji.emoji;
                    _isEmojiVisible = false;
                  });
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions),
                  onPressed: () {
                    setState(() {
                      _isEmojiVisible = !_isEmojiVisible;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
