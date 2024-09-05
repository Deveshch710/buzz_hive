import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:page_transition/page_transition.dart';
import 'package:buzz_hive/UI/root_page.dart';
import '../../../Constants.dart';  // Assuming you have a Constants file for common styles/colors

class photoget extends StatefulWidget {
  const photoget({Key? key}) : super(key: key);

  @override
  State<photoget> createState() => _photogetState();
}

class _photogetState extends State<photoget> {
  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _dpImage;
  List<File?> _images = List<File?>.filled(6, null);

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (index == -1) {
          _dpImage = File(pickedFile.path);
        } else {
          _images[index] = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _uploadImages() async {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please Wait. You will automatically redirect to home page', style:  TextStyle(color: Colors.black),),
        backgroundColor: Colors.yellow,
      ),
    );

    try {
      final user = _auth.currentUser;
      if (user != null && _dpImage != null) {
        final userId = user.uid;

        // Upload DP
        String dpUrl = await _uploadFile(_dpImage!, 'users/$userId/dp.jpg');

        // Upload other images
        List<String> imageUrls = [];
        for (int i = 0; i < _images.length; i++) {
          if (_images[i] != null) {
            String url = await _uploadFile(_images[i]!, 'users/$userId/img$i.jpg');
            imageUrls.add(url);
          } else {
            imageUrls.add('');
          }
        }

        // Save URLs to Firestore
        final userDoc = _firestore.collection('users').doc(userId);
        await userDoc.update({
          'dp': dpUrl,
          'img1url': imageUrls[0],
          'img2url': imageUrls[1],
          'img3url': imageUrls[2],
          'img4url': imageUrls[3],
          'img5url': imageUrls[4],
          'img6url': imageUrls[5],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Images uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          PageTransition(
            child: const RootPage(),
            type: PageTransitionType.bottomToTop,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least a DP and three images.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading images. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text('Upload Photos'),
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
                onTap: () => _pickImage(-1),
                child: _dpImage != null
                    ? Image.file(_dpImage!, height: 100, width: 100)
                    : Container(
                      color: Colors.grey[200],
                      height: 100,
                      width: 100,
                       child: const Icon(Icons.add_a_photo),
                ),
              ),
              const SizedBox(height: 50),
              Text(
                  'Upload Your Photo here',
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
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _pickImage(index),
                    child: _images[index] != null
                        ? Image.file(_images[index]!, fit: BoxFit.cover)
                        : Container(
                      color: Colors.grey[200],
                           child: const Icon(Icons.add_a_photo),
                    ),
                  );
                },
              ),
              const SizedBox(height: 90),
              ElevatedButton(
                onPressed: _uploadImages,
                child: const Text('Upload', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primarycolor,
                  minimumSize: const Size(60, 50,), // Set minimum width and height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Set corner radius for rectangle
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
