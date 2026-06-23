import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final TextEditingController usernameController =
TextEditingController();

final TextEditingController emailController =
TextEditingController();

String phoneNumber = "";

Future<void> registerUser(BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse(
        'http://10.0.2.2:3001/auth/register',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': usernameController.text,
        'email': emailController.text,
        'phone': phoneNumber,
        'password':"sahan123#",
      }),
    );
    print("Status Code ===============>: ${response.statusCode}");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");
    if (response.statusCode == 200 ||
        response.statusCode == 201) {

      showOtpBottomSheet(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network Error: $e'),
      ),
    );
  }
}

void showOtpBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text(
            'OTP Screen',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    },
  );
}