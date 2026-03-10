import 'package:flutter/material.dart';
import 'package:herodydemo/screens/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  PageController controller = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "image": "assets/images/front.jpg",
      "title": "Welcome\nAboard",
      "desc":
          "Discover a world of amazing features crafted just for you. Your journey begins here.",
      "gradient": [Color(0xFF0F0C29), Color(0xFF302B63)],
      "accent": Color(0xFF7B61FF),
      "tag": "01 — Explore",
    },
    {
      "image": "assets/images/front.jpg",
      "title": "\nEasily",
      "desc":
          "To- do,anytime, anywhere.",
      "gradient": [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
      "accent": Color(0xFF00D9C0),
      "tag": "02 — Connect",
    },
    {
      "image": "assets/images/front.jpg",
      "title": "Get\nStarted",
      "desc":
          "Your story starts with a single tap. Create your account and step into the experience.",
      "gradient": [Color(0xFF0D0D0D), Color(0xFF1C1C3A)],
      "accent": Color(0xFFFF6B6B),
      "tag": "03 — Begin",
    },
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _playEntryAnimation();
  }

  void _playEntryAnimation() {
    _fadeController.forward(from: 0);
    _slideController.forward(from: 0);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    controller.dispose();
    super.dispose();
  }

  Color get _currentAccent =>
      onboardingData[_currentPage]['accent'] as Color;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: onboardingData[_currentPage]['gradient'] as List<Color>,
          ),
        ),
        child: Stack(
          children: [
            // Decorative background orb
            Positioned(
              top: -80,
              right: -60,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 600),
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentAccent.withOpacity(0.08),
                ),
              ),
            ),

            // Bottom decorative orb
            Positioned(
              bottom: -100,
              left: -60,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 600),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentAccent.withOpacity(0.06),
                ),
              ),
            ),

            // Page content
            PageView.builder(
              controller: controller,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                _playEntryAnimation();
              },
              itemBuilder: (context, index) {
                return _buildPage(context, index, size);
              },
            ),

            // Top bar with skip
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 28,
              right: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo mark / brand
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _currentAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _currentAccent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentAccent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  // Skip button
                  if (_currentPage < onboardingData.length - 1)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 28,
              right: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: controller,
                    count: onboardingData.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _currentAccent,
                      dotColor: Colors.white.withOpacity(0.2),
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 4,
                      spacing: 6,
                    ),
                  ),

                  // CTA Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == onboardingData.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      } else {
                        controller.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _currentAccent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _currentAccent.withOpacity(0.45),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        _currentPage == onboardingData.length - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
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

  Widget _buildPage(BuildContext context, int index, Size size) {
    final data = onboardingData[index];
    final accent = data['accent'] as Color;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 90),

          // Image card
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: Container(
                  width: size.width - 56,
                  height: size.height * 0.35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.2),
                        blurRadius: 40,
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          data['image'],
                          fit: BoxFit.cover,
                        ),
                        // Gradient overlay on image
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.35),
                              ],
                            ),
                          ),
                        ),
                        // Tag badge
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data['tag'],
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 44),

          // Title
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Text(
                data['title'],
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.05,
                  letterSpacing: -1.0,
                ),
              ),
            ),
          ),

          SizedBox(height: 6),

          // Accent underline
          FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              width: 48,
              height: 3,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          SizedBox(height: 18),

          // Description
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Text(
                data['desc'],
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.55),
                  height: 1.65,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}