import 'package:buzz_hive/UI/root_page.dart';
import 'package:buzz_hive/UI/screen/signin_screens/photogeeting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';  // Import for input formatting

import '../../../Constants.dart';
import '../../../models/textfields.dart';

class BasicDetailPage extends StatefulWidget {
  const BasicDetailPage({Key? key}) : super(key: key);

  @override
  State<BasicDetailPage> createState() => _BasicDetailPageState();
}

class _BasicDetailPageState extends State<BasicDetailPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();

  List<String> _genders = ['Male', 'Female', 'Other'];
  List<String> _branches = ['CS', 'IT', 'ECE', 'EEE', 'ICE'];
  List<String> _years = ['1st', '2nd', '3rd', '4th', 'Passed Out'];
  List<String> _collegeNames = ['Bvcoe'];
  String? _selectedGender;
  String? _selectedBranch;
  String? _selectedYear;
  String? _selectedCollegeName;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _emailController.text = _auth.currentUser?.email ?? ''; // Set email automatically
  }

  bool allFieldsFilled() {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _dobController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneNoController.text.isNotEmpty &&
        _rollNoController.text.isNotEmpty &&
        _selectedGender != null &&
        _selectedBranch != null &&
        _selectedYear != null &&
        _selectedCollegeName != null;
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> saveUserDataToFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData = {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'dob': _dobController.text,
          'email': _emailController.text,
          'phoneNo': int.tryParse(_phoneNoController.text),
          'gender': _selectedGender,
          'collegeName': _selectedCollegeName,
          'rollNumber': int.tryParse(_rollNoController.text),
          'branch': _selectedBranch,
          'year': _selectedYear,
        };
        await _firestore.collection('users').doc(user.uid).set(userData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Now Upload Your Image'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          PageTransition(
            child: const photoget(),
            type: PageTransitionType.bottomToTop,
          ),
        );
      }
    } catch (e) {
      showErrorSnackBar('Error saving data. Please try again.');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.back,
      appBar: AppBar(
        title: const Text('Basic Details'),
        backgroundColor: Constants.primarycolor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Constants.secondarycolor,
                ),
              ),
              const SizedBox(height: 10.0),
              CustomTextfield(
                icon: Icons.person,
                obscureText: false,
                hintText: 'First Name',
                controller: _firstNameController,
              ),
              const SizedBox(height: 5.0),
              CustomTextfield(
                icon: Icons.person_add_alt_1,
                obscureText: false,
                hintText: 'Last Name',
                controller: _lastNameController,
              ),
              const SizedBox(height: 5.0),
              CustomTextfield(
                icon: Icons.calendar_today,
                obscureText: false,
                hintText: 'Date of Birth (DD-MM-YYYY)',
                controller: _dobController,
                readOnly: true,  // Prevent manual input
                onTap: () => _selectDate(context), // Open date picker on tap
              ),
              const SizedBox(height: 5.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                value: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                items: _genders.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
              ),
              const SizedBox(height: 5.0),
              CustomTextfield(
                icon: Icons.email,
                obscureText: false,
                hintText: 'Email',
                controller: _emailController,
                enabled: false, // Disable editing of the email field
              ),
              const SizedBox(height: 5.0),
              CustomTextfield(
                icon: Icons.phone,
                obscureText: false,
                hintText: 'Phone Number',
                controller: _phoneNoController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Restrict input to digits
              ),
              const SizedBox(height: 30.0),
              Text(
                'College Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Constants.secondarycolor,
                ),
              ),
              const SizedBox(height: 5.0),
              CustomTextfield(
                icon: Icons.confirmation_number_outlined,
                obscureText: false,
                hintText: 'Roll Number',
                controller: _rollNoController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Restrict input to digits
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'College Name',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCollegeName,
                onChanged: (value) {
                  setState(() {
                    _selectedCollegeName = value;
                  });
                },
                items: _collegeNames.map((collegeName) {
                  return DropdownMenuItem<String>(
                    value: collegeName,
                    child: Text(collegeName),
                  );
                }).toList(),
              ),
              const SizedBox(height: 5.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'Branch',
                  border: OutlineInputBorder(),
                ),
                value: _selectedBranch,
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value;
                  });
                },
                items: _branches.map((branch) {
                  return DropdownMenuItem<String>(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
              ),
              const SizedBox(height: 5.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'Year',
                  border: OutlineInputBorder(),
                ),
                value: _selectedYear,
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value;
                  });
                },
                items: _years.map((year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!allFieldsFilled()) {
            showErrorSnackBar('Please fill in all required fields.');
          } else {
            saveUserDataToFirebase();
          }
        },
        child: const Icon(Icons.arrow_forward_ios),
        backgroundColor: Constants.primarycolor,
      ),
    );
  }
}
