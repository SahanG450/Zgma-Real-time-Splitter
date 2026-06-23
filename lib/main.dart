import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/getstart.dart';
import 'pages/intro.dart';
import 'pages/home.dart';
import 'pages/controllers/homePageloginController.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const ZgmaApp());
}

class ZgmaApp extends StatelessWidget {
  const ZgmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zgma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: '.SF Pro Display',
        scaffoldBackgroundColor: Colors.black,
      ),

      // ✅ Use initialRoute + routes (not home:)
      initialRoute: '/',
      routes: {
        '/':          (context) => const WelcomePage(),
        '/getstart':  (context) => const GetStartPage(),
        '/register':  (context) => const RegisterPage(),
        '/intro': (context) => const IntroPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.1,
                colors: [
                  Color(0xFF1C1C2E),
                  Color(0xFF0A0A14),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Soft glow orb
          Positioned(
            top: size.height * 0.18,
            left: size.width * 0.5 - 110,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E5CE6).withOpacity(0.35),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // App Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF7B79FF),
                              Color(0xFF5E5CE6),
                              Color(0xFF3A38C4),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5E5CE6).withOpacity(0.55),
                              blurRadius: 36,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Z',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // App Name
                      const Text(
                        'Zgma',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.0,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tagline
                      Text(
                        'A smarter way to get things done.\nSimple. Fast. Yours.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.55),
                          height: 1.55,
                          letterSpacing: 0.1,
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Get Started Button ✅ fixed route
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(context, '/register'); // ✅ no trailing slash
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E5CE6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Sign In Button ✅ fixed route
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: TextButton(
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

                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      border: const Border(
                                        top: BorderSide(
                                        color: const Color(0xFFC0C0C0), // border color
                                        width: 2,            // border thickness
                                      ),
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                  ),

                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: [

                                      const Center(
                                        child: Text(
                                          'Sign in to Zgma',
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
                                          'Enter your email and password to Logig sucessfully(tempory Solution)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 28),


                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.email,
                                      color: Colors.white54,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white10,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Colors.white24,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Colors.deepPurple,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter email';
                                    }
                                    return null;
                                  },
                                ),



                                TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(
                                color: Colors.white54,
                                ),
                                prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.white54,
                                ),
                                filled: true,
                                fillColor: Colors.white10,
                                enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                color: Colors.white24,
                                ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                color: Colors.deepPurple,
                                width: 2,
                                ),
                                ),
                                ),
                                validator: (value) {
                                if (value == null || value.isEmpty) {
                                return 'Enter password';
                                }
                                return null;
                                },
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
                                              loginUser(context);
                                            },
                                          child: const Text(
                                            'Login',
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
                                  ),
                                );
                              },
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            // otp

                            //otp
                            'Sign In',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.85),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Legal footer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.3),
                              height: 1.5,
                            ),
                            children: const [
                              TextSpan(text: 'By continuing, you agree to our '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: Color(0xFF5E5CE6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: Color(0xFF5E5CE6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}