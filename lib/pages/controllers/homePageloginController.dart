import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../home.dart';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController =TextEditingController();
Future<void> loginUser(BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse(
        'http://localhost:3001/auth/login',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': emailController.text.trim(),
        'password': passwordController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ?? 'Login Failed',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}