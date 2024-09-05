import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendRequestPanel extends StatelessWidget {
  final Function onClose;

  const FriendRequestPanel({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Friend Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => onClose(),
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('friend_requests')
                .doc(user!.uid)
                .collection('requests')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final requests = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final senderId = request['sender_id'];
                  final senderName = request['sender_name'];
                  final senderDp = request['sender_dp'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(senderDp),
                    ),
                    title: Text(senderName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () async {
                            // Accept friend request logic
                            await FirebaseFirestore.instance
                                .collection('friends')
                                .doc(user.uid)
                                .collection('userFriends')
                                .doc(senderId)
                                .set({
                              'friend_id': senderId,
                              'friend_name': senderName,
                              'friend_dp': senderDp,
                            });

                            // Update request status
                            await request.reference.update({'status': 'accepted'});
                          },
                          child: Text('Accept'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Reject friend request logic
                            await request.reference.update({'status': 'rejected'});
                          },
                          child: Text('Reject'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
