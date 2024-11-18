import 'package:buzz_hive/UI/screen/signin_screens/photogeeting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../../Constants.dart'; // Import your constants for colors and styles

class InterestSelectionPage extends StatefulWidget {
  @override
  _InterestSelectionPageState createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<InterestSelectionPage> {
  List<String> interests = [
    "Traveling",
    "Gaming",
    "Music",
    "Art",
    "Technology",
    "Fitness",
    "Photography",
    "Reading",
    "Cooking",
    "Sports",
    "AI",
    "Event Management",
    "Startup",
    "Research",
  ];

  List<String> selectedInterests = [];
  bool isLoading = false; // To handle loading state during Firebase save

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Interests"),
        backgroundColor: Constants.primarycolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 3,
                ),
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  final interest = interests[index];
                  final isSelected = selectedInterests.contains(interest);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedInterests.remove(interest);
                        } else {
                          selectedInterests.add(interest);
                        }
                      });
                    },
                    child: Card(
                      color: isSelected ? Constants.secondarycolor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: isSelected ? Colors.blueAccent : Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          interest,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator()) // Show loading indicator
                : Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedInterests.isNotEmpty) {
                    setState(() {
                      isLoading = true;
                    });

                    try {

                      // Navigate to the 'PhotoGet' page
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                          child: photoget(),
                          type: PageTransitionType.bottomToTop,
                        ),);
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving interests: $error')),
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one interest')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.secondarycolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 50.0,
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
