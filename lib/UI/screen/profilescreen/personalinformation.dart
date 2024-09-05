import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Constants.dart';
import '../../../models/textfields.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNoController;
  late TextEditingController _rollNumberController;

  String? _selectedYear;
  String? _selectedBranch;

  final List<String> _years = ['1', '2', '3', '4', 'Passed Out'];
  final List<String> _branches = ['CS', 'IT', 'ECE', 'EEE', 'ICE'];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNoController = TextEditingController();
    _rollNumberController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        _firstNameController.text = data?['firstName'] ?? '';
        _lastNameController.text = data?['lastName'] ?? '';
        _emailController.text = data?['email'] ?? '';
        _phoneNoController.text = data?['phoneNo'] ?? '';
        _rollNumberController.text = data?['rollNumber']?.toString() ?? '';
        _selectedYear = data?['year'];
        _selectedBranch = data?['branch'];

        // Ensure the selected values are valid
        if (!_years.contains(_selectedYear)) _selectedYear = null;
        if (!_branches.contains(_selectedBranch)) _selectedBranch = null;

        setState(() {});
      }
    }
  }

  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _formKey.currentState?.validate() == true) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phoneNo': _phoneNoController.text,
        'rollNumber': int.tryParse(_rollNumberController.text),
        'year': _selectedYear,
        'branch': _selectedBranch,
      });
      Navigator.pop(context); // Navigate back to profile page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.back,
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Constants.primarycolor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextfield(
                  icon: Icons.person,
                  obscureText: false,
                  hintText: 'First Name',
                  controller: _firstNameController,
                ),
                const SizedBox(height: 16.0),
                CustomTextfield(
                  icon: Icons.person_add_alt_1,
                  obscureText: false,
                  hintText: 'Last Name',
                  controller: _lastNameController,
                ),
                const SizedBox(height: 16.0),
                CustomTextfield(
                  icon: Icons.email,
                  obscureText: false,
                  hintText: 'Email',
                  controller: _emailController,
                  enabled: false, // Disable editing of the email field
                ),
                const SizedBox(height: 16.0),
                CustomTextfield(
                  icon: Icons.phone,
                  obscureText: false,
                  hintText: 'Phone No',
                  controller: _phoneNoController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),
                CustomTextfield(
                  icon: Icons.confirmation_number,
                  obscureText: false,
                  hintText: 'Roll No',
                  controller: _rollNumberController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    hintText: 'Year',
                    border: OutlineInputBorder(),
                  ),
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
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedBranch,
                  decoration: const InputDecoration(
                    hintText: 'Branch',
                    border: OutlineInputBorder(),
                  ),
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
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your branch';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 130),
                ElevatedButton(
                  onPressed: _updateUserData,
                  child: const Text('Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primarycolor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
