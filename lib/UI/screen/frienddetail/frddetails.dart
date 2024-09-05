import 'package:buzz_hive/Constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../../models/event.dart';

class DetailPage extends StatelessWidget {
  final details user;

  const DetailPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.back,
      appBar: AppBar(
        title: Text('${user.firstname} ${user.lastname}'),
        backgroundColor: Constants.primarycolor,
      ),

      body: Hero(
        tag: user.emailid,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel for images
              if (_userHasImages(user))
                CarouselSlider(
                  items: [
                    _buildImage(user.img1url),
                    _buildImage(user.img2url),
                    _buildImage(user.img3url),
                    _buildImage(user.img4url),
                    _buildImage(user.img5url),
                    _buildImage(user.img6url),
                  ],
                  options: CarouselOptions(
                    height: 400,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: Duration(milliseconds: 1500),
                    viewportFraction: 0.9,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstname} ${user.lastname}',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Constants.secondarycolor),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(height: 8),
                    Text('Date of Birth: ${user.dateofbirth}', style: TextStyle(fontSize: 15, color: Constants.blackColor)),
                    SizedBox(height: 8),
                    Text('Gender: ${user.gender}', style: TextStyle(fontSize: 15, color: Constants.blackColor)),
                    SizedBox(height: 8),
                    Text('College: ${user.collegename}', style: TextStyle(fontSize: 15, color: Constants.blackColor)),
                    SizedBox(height: 8),
                    Text('Branch: ${user.branch}', style: TextStyle(fontSize: 15, color: Constants.blackColor)),
                    SizedBox(height: 8),
                    Text('Year: ${user.year}', style: TextStyle(fontSize: 15, color: Constants.blackColor)),
                    SizedBox(height: 8),
                    Text('Phone: ${user.phoneno}', style: TextStyle(fontSize: 15, color: Constants.blackColor)),
                    SizedBox(height: 8),
                    Text('Instagram: ${user.insta}', style: TextStyle(fontSize: 15, color: Constants.blackColor)),
                    SizedBox(height: 8),
                    Text('LinkedIn: ${user.linkedin}', style: TextStyle(fontSize: 15, color: Constants.blackColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: url.isNotEmpty
                  ? Image.network(
                url,
                height: 400,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.image_not_supported, size: 120),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.2), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _userHasImages(details user) {
    return user.img1url.isNotEmpty ||
        user.img2url.isNotEmpty ||
        user.img3url.isNotEmpty ||
        user.img4url.isNotEmpty ||
        user.img5url.isNotEmpty ||
        user.img6url.isNotEmpty;
  }
}
