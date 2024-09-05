import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Constants.dart';

class CustomTextfield extends StatelessWidget {
  final IconData icon;
  final bool obscureText;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType; // Add keyboardType parameter
  final List<TextInputFormatter>? inputFormatters; // Add inputFormatters parameter
  final VoidCallback? onTap; // Add onTap parameter
  final bool readOnly; // Add readOnly parameter
  final bool enabled; // Add enabled parameter

  const CustomTextfield({
    Key? key,
    required this.icon,
    required this.obscureText,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text, // Default to TextInputType.text
    this.inputFormatters, // Optional parameter
    this.onTap, // Optional parameter
    this.readOnly = false, // Default to false
    this.enabled = true, // Default to true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey, // Adjust the border color as needed
          width: 1.0, // Adjust the border width as needed
        ),
        borderRadius: BorderRadius.circular(5.0), // Add rounded corners if desired
      ),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        keyboardType: keyboardType, // Set keyboardType
        inputFormatters: inputFormatters, // Set inputFormatters
        onTap: onTap, // Set onTap
        readOnly: readOnly, // Set readOnly
        enabled: enabled, // Set enabled
        style: TextStyle(
          color: Constants.blackColor,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Constants.blackColor.withOpacity(.3)),
          hintText: hintText,
        ),
        cursorColor: Constants.blackColor.withOpacity(.5),
      ),
    );
  }
}
