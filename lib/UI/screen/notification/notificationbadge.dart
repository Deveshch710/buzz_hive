import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestPanel extends StatelessWidget {
  final VoidCallback onClose; // Corrected the type to VoidCallback

  const FriendRequestPanel({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      width: MediaQuery.of(context).size.width, // Full width
      height: MediaQuery.of(context).size.height * 0.0, // Adjust height as needed
      color: Colors.white,
      child: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: ListTile(
              title: Text('Notifications'),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: onClose,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('friend_requests')
                  .doc(currentUser?.uid)
                  .collection('requests')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final senderName = request['sender_name'];
                    final senderDp = request['sender_dp'];
                    final requestId = request.id;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(senderDp),
                      ),
                      title: Text(senderName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _acceptRequest(requestId),
                            child: Text('Accept'),
                          ),
                          TextButton(
                            onPressed: () => _rejectRequest(requestId),
                            child: Text('Reject'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest(String requestId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final requestDoc = FirebaseFirestore.instance.collection('friend_requests')
          .doc(currentUser.uid)
          .collection('requests')
          .doc(requestId);

      await requestDoc.update({'status': 'accepted'});
      // Add logic to add the friend in both users' friend lists

      // Notify sender about acceptance
      final requestData = await requestDoc.get();
      final senderId = requestData['sender_id'];
      await FirebaseFirestore.instance.collection('friend_requests')
          .doc(senderId)
          .collection('requests')
          .doc(requestId)
          .update({'status': 'accepted'});

      print('Friend request accepted');
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final requestDoc = FirebaseFirestore.instance.collection('friend_requests')
          .doc(currentUser.uid)
          .collection('requests')
          .doc(requestId);

      await requestDoc.update({'status': 'rejected'});

      // Notify sender about rejection
      final requestData = await requestDoc.get();
      final senderId = requestData['sender_id'];
      await FirebaseFirestore.instance.collection('friend_requests')
          .doc(senderId)
          .collection('requests')
          .doc(requestId)
          .update({'status': 'rejected'});

      print('Friend request rejected');
    }
  }
}
