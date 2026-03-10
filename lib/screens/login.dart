import 'package:flutter/material.dart';
import 'package:herodydemo/screens/otp.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  bool _isFocused = false;
  bool _hasText = false;

  // Matches onboarding accent: violet → this page uses teal-ish #00D9C0 feel
  // but we pick a fresh identity: deep navy + golden accent
  static const Color _accent = Color(0xFF7B61FF);
  static const Color _bgTop = Color(0xFF0F0C29);
  static const Color _bgBottom = Color(0xFF302B63);

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();

    _phoneFocus.addListener(() {
      setState(() => _isFocused = _phoneFocus.hasFocus);
    });

    phoneController.addListener(() {
      setState(() => _hasText = phoneController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _phoneFocus.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String _selectedCountry = "+91";

  final List<String> _countryCodes = ["+91", "+1", "+44", "+61", "+971"];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bgTop,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative orbs ──────────────────────────────────────
            Positioned(
              top: -100,
              right: -80,
              child: ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withOpacity(0.07),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withOpacity(0.05),
                ),
              ),
            ),

            // Tiny decorative dots grid
            Positioned(
              top: size.height * 0.28,
              right: 28,
              child: Opacity(
                opacity: 0.12,
                child: _DotsGrid(color: _accent),
              ),
            ),

            // ── Main content ─────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Back button
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Heading
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _accent.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "Authentication",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _accent,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Title
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Enter your\n",
                                    style: TextStyle(
                                      fontFamily: 'Playfair Display',
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.1,
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Phone",
                                    style: TextStyle(
                                      fontFamily: 'Playfair Display',
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      color: _accent,
                                      height: 1.1,
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Underline
                            Container(
                              width: 48,
                              height: 3,
                              decoration: BoxDecoration(
                                color: _accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              "We'll send a one-time verification code\nto confirm your identity.",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withOpacity(0.5),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 52),

                    // Phone input
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MOBILE NUMBER",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.35),
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 12),

                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _isFocused
                                      ? _accent.withOpacity(0.6)
                                      : Colors.white.withOpacity(0.1),
                                  width: _isFocused ? 1.5 : 1,
                                ),
                                boxShadow: _isFocused
                                    ? [
                                        BoxShadow(
                                          color: _accent.withOpacity(0.12),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  // Country code picker
                                  GestureDetector(
                                    onTap: () => _showCountryPicker(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 20),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            _selectedCountry,
                                            style: const TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color:
                                                Colors.white.withOpacity(0.4),
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Number input
                                  Expanded(
                                    child: TextField(
                                      controller: phoneController,
                                      focusNode: _phoneFocus,
                                      keyboardType: TextInputType.phone,
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "000 000 0000",
                                        hintStyle: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color:
                                              Colors.white.withOpacity(0.2),
                                          letterSpacing: 2,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 20),
                                      ),
                                    ),
                                  ),

                                  // Clear / check icon
                                  if (_hasText)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 14),
                                      child: GestureDetector(
                                        onTap: () => phoneController.clear(),
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: _accent.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            color:
                                                _accent.withOpacity(0.8),
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                "Standard SMS rates may apply",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // CTA Button
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: GestureDetector(
                          onTap: _hasText
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OtpScreen(
                                        phone: phoneController.text,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 62,
                            decoration: BoxDecoration(
                              color: _hasText
                                  ? _accent
                                  : _accent.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: _hasText
                                  ? [
                                      BoxShadow(
                                        color: _accent.withOpacity(0.45),
                                        blurRadius: 28,
                                        offset: const Offset(0, 12),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Send OTP",
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: _hasText
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.4),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _hasText
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: _hasText
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Divider
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "or continue with",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Social login row
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialButton(
                            label: "Google",
                            icon: Icons.g_mobiledata_rounded,
                          ),
                          const SizedBox(width: 16),
                          _SocialButton(
                            label: "Apple",
                            icon: Icons.apple_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1733),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Country Code",
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ..._countryCodes.map((code) => ListTile(
                  title: Text(
                    code,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  trailing: _selectedCountry == code
                      ? const Icon(Icons.check_rounded, color: _accent)
                      : null,
                  onTap: () {
                    setState(() => _selectedCountry = code);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SocialButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsGrid extends StatelessWidget {
  final Color color;

  const _DotsGrid({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 16,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}