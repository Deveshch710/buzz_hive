import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:buzz_hive/UI/root_page.dart';
import '../../../Constants.dart';

class UpdatePhotosPage extends StatefulWidget {
  const UpdatePhotosPage({Key? key}) : super(key: key);

  @override
  State<UpdatePhotosPage> createState() => _UpdatePhotosPageState();
}

class _UpdatePhotosPageState extends State<UpdatePhotosPage> {
  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _dpUrl;
  List<String?> _imageUrls = List<String?>.filled(6, null);

  @override
  void initState() {
    super.initState();
    _loadUserImages();
  }

  Future<void> _loadUserImages() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _dpUrl = data?['dp'];
          _imageUrls[0] = data?['img1url'];
          _imageUrls[1] = data?['img2url'];
          _imageUrls[2] = data?['img3url'];
          _imageUrls[3] = data?['img4url'];
          _imageUrls[4] = data?['img5url'];
          _imageUrls[5] = data?['img6url'];
        });
      }
    }
  }

  Future<void> _pickAndUploadImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please Wait. Your Image is Uploading', style:  TextStyle(color: Colors.black),),
        backgroundColor: Colors.yellow,
      ),
    );

    if (pickedFile != null) {
      final user = _auth.currentUser;
      if (user != null) {
        final file = File(pickedFile.path);
        String path = 'users/${user.uid}/img$index.jpg';

        if (index == -1) {
          path = 'users/${user.uid}/dp.jpg';
        }

        String imageUrl = await _uploadFile(file, path);

        setState(() {
          if (index == -1) {
            _dpUrl = imageUrl;
            _firestore.collection('users').doc(user.uid).update({'dp': imageUrl});
          } else {
            _imageUrls[index] = imageUrl;
            _firestore.collection('users').doc(user.uid).update({'img${index + 1}url': imageUrl});
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image updated successfully!', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<String> _uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.back,
      appBar: AppBar(
        title: const Text('Update Photos'),
        backgroundColor: Constants.primarycolor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Select Display Picture:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Constants.secondarycolor,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pickAndUploadImage(-1),
                child: _dpUrl != null
                    ? CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(_dpUrl!),
                )
                    : CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.add_a_photo),
                ),
              ),
              const SizedBox(height: 50),
              Text(
                'Upload Your Photos here:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Constants.secondarycolor,
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _pickAndUploadImage(index),
                    child: _imageUrls[index] != null
                        ? Stack(
                        fit: StackFit.expand,
                        children: [
                        Image.network(
                          _imageUrls[index]!,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.add_a_photo, color: Colors.grey),
                            onPressed: () => _pickAndUploadImage(index),
                          ),
                        ),
                      ],
                    )
                        : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.add_a_photo),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
