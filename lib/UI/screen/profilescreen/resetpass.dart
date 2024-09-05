import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Constants.dart';
import '../../../models/textfields.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isCurrentPasswordVerified = false;

  Future<void> _verifyCurrentPassword() async {
    final user = _auth.currentUser;
    if (user != null) {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      try {
        await user.reauthenticateWithCredential(credential);
        setState(() {
          _isCurrentPasswordVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password verified! You can now set a new password.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect current password.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text == _confirmPasswordController.text) {
      try {
        await _auth.currentUser?.updatePassword(_newPasswordController.text);

        // Reset all values after successful update
        setState(() {
          _isCurrentPasswordVerified = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating password.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.back,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Constants.primarycolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Current Password:',
              style: TextStyle(
                fontSize: 16,
                color: Constants.secondarycolor,
              ),
            ),
            const SizedBox(height: 10),
            CustomTextfield(
              icon: Icons.lock,
              obscureText: true,
              hintText: 'Current Password',
              controller: _currentPasswordController,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _verifyCurrentPassword,
              child: const Text('Verify Password',style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primarycolor,
                textStyle: const TextStyle(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (_isCurrentPasswordVerified) ...[
              const SizedBox(height: 20),
              Text(
                'Enter New Password:',
                style: TextStyle(
                  fontSize: 16,
                  color: Constants.secondarycolor,
                ),
              ),
              const SizedBox(height: 10),
              CustomTextfield(
                icon: Icons.lock_outline,
                obscureText: true,
                hintText: 'New Password',
                controller: _newPasswordController,
              ),
              const SizedBox(height: 10),
              CustomTextfield(
                icon: Icons.lock_outline,
                obscureText: true,
                hintText: 'Confirm New Password',
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePassword,
                child: const Text('Update Password',style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primarycolor,
                  textStyle: const TextStyle(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
