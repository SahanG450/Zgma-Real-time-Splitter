import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class GetStartPage extends StatelessWidget {
  const GetStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Get Started')),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Create Account'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text('Create an Account',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const Text("Minimal info required.You can add Profile photo later.", style: TextStyle(color: Colors.white24,)),
            const SizedBox(height: 32),

            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'User Name',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            IntlPhoneField(
              style: const TextStyle(
                color: Colors.white, // phone number text color
              ),
              dropdownTextStyle: const TextStyle(
                color: Colors.white, // country code text color
              ),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: const TextStyle(
                  color: Colors.white54, // label color
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),


                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),

                  borderSide: const BorderSide(
                    color: Colors.white24, // focused border color
                    width: 2,
                  ),
                ),
              ),

              initialCountryCode: 'LK',

              onChanged: (phone) {
                print(phone.completeNumber);
              },
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E5CE6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                  onPressed: () {
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
                        return Padding(
                          padding: const EdgeInsets.all(24),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              const Center(
                                child: Text(
                                  'Confirm OTP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Center(
                                child: Text(
                                  'Enter the 5 digit code sent to your phone',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white54,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              TextField(
                                keyboardType: TextInputType.number,
                                maxLength: 5,

                                style: const TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 12,
                                  fontSize: 24,
                                ),

                                textAlign: TextAlign.center,

                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: '• • • • •',

                                  hintStyle: const TextStyle(
                                    color: Colors.white24,
                                  ),

                                  filled: true,
                                  fillColor: Colors.white10,

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 52,

                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5E5CE6),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),

                                  onPressed: () {
                                    Navigator.pop(context);

                                    Navigator.pushReplacementNamed(context, '/intro');
                                  },

                                  child: const Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                            ],
                          ),
                        );
                      },
                    );
                  },
                child: const Text('Create Account',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

