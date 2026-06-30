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
        'password':"c",
      }),
    );
    print("Status Code ===============>: ${response.statusCode}");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");
    if (response.statusCode == 200 ||
        response.statusCode == 201) {

      showProfileSetupBottomSheet(context);

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



void showProfileSetupBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: 450,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Complete Your Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Add a profile photo to help others identify you easily.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1F1F1F),
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                // Open Image Picker Here
              },
              icon: const Icon(Icons.upload),
              label: const Text("Upload Photo"),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showBankDetailsBottomSheet(context);
                },
                child: const Text("Continue"),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Skip for Now",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    },
  );
}


void showBankDetailsBottomSheet(BuildContext context) {
  final bankController = TextEditingController();
  final accountController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: 500,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const Text(
              "Add Bank Account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Link a bank account to receive payments.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: bankController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Bank Name",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: accountController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Account Number",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Save Bank Details API
                  Navigator.pop(context);
                },
                child: const Text("Save Bank Details"),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Skip for Now",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    },
  );
}

