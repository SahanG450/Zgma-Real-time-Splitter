import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color _accent = Color(0xFF5E5CE6);
  static const Color _bg = Color(0xFF0A0A14);

  final List<_IntroSlide> _slides = const [
    _IntroSlide(
      // ADD IMAGE: place your image at assets/images/intro_1.png
      // (restaurant / bill splitting scene)
      imagePath: 'lib/assets/image/intro_1.png',
      title: 'Split the bill\nin seconds',
      body:
      'Scan a QR session, add who\'s in, and split evenly or customise amounts — no mental maths needed.',
    ),
    _IntroSlide(
      // ADD IMAGE: place your image at assets/images/intro_2.png
      // (taxi / transport scene)
      imagePath: 'lib/assets/image/intro_2.png',
      title: 'Share taxi & trip costs\neffortlessly',
      body:
      'Quickly split fares among riders and send payment requests via QR code or contact lookup.',
    ),
    _IntroSlide(
      // ADD IMAGE: place your image at assets/images/intro_3.png
      // (wallet / payment scene)
      imagePath: 'lib/assets/image/intro_3.png',
      title: 'Track & settle\nbalances instantly',
      body:
      'Add shared expenses, track who paid, and clear balances in one tap through SmartPay Wallet.',
    ),
    _IntroSlide(
      // ADD IMAGE: place your image at assets/images/intro_4.png
      // (group trip / friends scene)
      imagePath: 'lib/assets/image/intro_4.png',
      title: 'Group trips\nmade simple',
      body:
      'Track shared expenses, assign items to people, and settle with one tap using secure payments.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skip() {
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _start() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    opacity: isLast ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: _skip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) =>
                    _SlideView(slide: _slides[index]),
              ),
            ),

            // Dots + buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active
                              ? _accent
                              : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Next / Start button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: isLast
                        ? _PrimaryButton(
                      key: const ValueKey('start'),
                      label: 'Start SmartPay',
                      onTap: _start,
                    )
                        : _PrimaryButton(
                      key: const ValueKey('next'),
                      label: 'Next',
                      onTap: _next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Slide data model ───────────────────────────────────────────────────────

class _IntroSlide {
  final String imagePath;
  final String title;
  final String body;
  const _IntroSlide({
    required this.imagePath,
    required this.title,
    required this.body,
  });
}

// ─── Slide view ──────────────────────────────────────────────────────────────

class _SlideView extends StatelessWidget {
  final _IntroSlide slide;
  const _SlideView({required this.slide});

  static const Color _card = Color(0xFF161628);
  static const Color _border = Color(0xFF2A2A45);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // ── Image area ────────────────────────────────────────────────────
          // ADD IMAGE: declare your assets in pubspec.yaml like this:
          //   flutter:
          //     assets:
          //       - assets/images/intro_1.png
          //       - assets/images/intro_2.png
          //       - assets/images/intro_3.png
          //       - assets/images/intro_4.png
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              slide.imagePath,
              width: double.infinity,
              height: 460,
              fit: BoxFit.cover,
              // Shown while the image loads
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) return child;
                return Container(
                  width: double.infinity,
                  height: 460,
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border),
                  ),
                );
              },
              // Shown if the asset path is wrong or image is missing
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 460,
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined,
                          size: 48, color: Color(0xFF2A2A45)),
                      SizedBox(height: 10),
                      Text(
                        'Add image here',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF3A3A55),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // ─────────────────────────────────────────────────────────────────

          const SizedBox(height: 36),

          // Title
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.6,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          // Body
          Text(
            slide.body,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.45),
              height: 1.65,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


// ─── Small components ────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5E5CE6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}