import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:herodydemo/screens/home.dart';

class CreateProfileScreen extends StatefulWidget {
  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen>
    with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  bool _isFocused = false;
  bool _hasText = false;
  bool _isLoading = false;

  static const Color _accent = Color(0xFF7B61FF);
  static const Color _bgTop = Color(0xFF0F0C29);
  static const Color _bgBottom = Color(0xFF302B63);

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  late AnimationController _successController;
  late Animation<double> _successScaleAnim;
  late Animation<double> _successFadeAnim;

  bool _showSuccess = false;

  // Avatar selector
  final List<String> _avatarEmojis = [
    '🦊', '🐺', '🦁', '🐯', '🐻', '🦄', '🐸', '🦋',
  ];
  int _selectedAvatar = 0;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryController, curve: Curves.easeOutCubic));

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _successController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut));
    _successFadeAnim = CurvedAnimation(
        parent: _successController, curve: Curves.easeOut);

    _entryController.forward();

    _nameFocus.addListener(() {
      setState(() => _isFocused = _nameFocus.hasFocus);
    });
    nameController.addListener(() {
      setState(() => _hasText = nameController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _nameFocus.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_hasText || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "uid": user.uid,
        "name": nameController.text.trim(),
        "phone": user.phoneNumber,
        "avatar": _avatarEmojis[_selectedAvatar],
        "createdAt": DateTime.now(),
      });

      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });
      _successController.forward();

      await Future.delayed(const Duration(milliseconds: 1400));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Something went wrong. Please try again.",
            style: const TextStyle(fontFamily: 'Outfit'),
          ),
          backgroundColor: const Color(0xFF1A1733),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // ── Decorative orbs ─────────────────────────────────
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

            // ── Main scrollable content ──────────────────────────
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
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 44),

                    // ── Header ────────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _accent.withOpacity(0.3), width: 1),
                              ),
                              child: Text(
                                "Profile Setup",
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

                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Tell us your\n",
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
                                    text: "Name",
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
                              "This is how others will see you.\nChoose something you love.",
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

                    const SizedBox(height: 44),

                    // ── Avatar picker ─────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PICK AN AVATAR",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.35),
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 14),

                            SizedBox(
                              height: 68,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _avatarEmojis.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, i) {
                                  final selected = _selectedAvatar == i;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedAvatar = i),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? _accent.withOpacity(0.2)
                                            : Colors.white.withOpacity(0.05),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        border: Border.all(
                                          color: selected
                                              ? _accent.withOpacity(0.7)
                                              : Colors.white.withOpacity(0.1),
                                          width: selected ? 1.5 : 1,
                                        ),
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: _accent
                                                      .withOpacity(0.25),
                                                  blurRadius: 14,
                                                  spreadRadius: 1,
                                                )
                                              ]
                                            : [],
                                      ),
                                      child: Center(
                                        child: Text(
                                          _avatarEmojis[i],
                                          style:
                                              const TextStyle(fontSize: 28),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Name input ────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DISPLAY NAME",
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
                                  // Avatar preview
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      _avatarEmojis[_selectedAvatar],
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),

                                  // Text input
                                  Expanded(
                                    child: TextField(
                                      controller: nameController,
                                      focusNode: _nameFocus,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "e.g. Alex Rivera",
                                        hintStyle: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color:
                                              Colors.white.withOpacity(0.2),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 20),
                                      ),
                                    ),
                                  ),

                                  // Clear button
                                  if (_hasText)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 14),
                                      child: GestureDetector(
                                        onTap: () => nameController.clear(),
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color:
                                                _accent.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: _accent.withOpacity(0.8),
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Character count
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Your name will be visible to everyone",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.25),
                                    ),
                                  ),
                                  Text(
                                    "${nameController.text.length}/30",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      color: nameController.text.length > 25
                                          ? const Color(0xFFFF6B6B)
                                          : Colors.white.withOpacity(0.25),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ── CTA Button ────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: GestureDetector(
                        onTap: _createUser,
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
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Create Account",
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: _hasText
                                              ? Colors.white
                                              : Colors.white
                                                  .withOpacity(0.4),
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 300),
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _hasText
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.white
                                                  .withOpacity(0.06),
                                          borderRadius:
                                              BorderRadius.circular(10),
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

                    const SizedBox(height: 32),

                    // ── Terms note ────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.25),
                              height: 1.6,
                            ),
                            children: [
                              const TextSpan(
                                  text:
                                      "By continuing you agree to our "),
                              TextSpan(
                                text: "Terms of Service",
                                style: TextStyle(
                                  color: _accent.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  color: _accent.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Success overlay ────────────────────────────────────
            if (_showSuccess)
              Container(
                color: Colors.black.withOpacity(0.65),
                child: Center(
                  child: ScaleTransition(
                    scale: _successScaleAnim,
                    child: FadeTransition(
                      opacity: _successFadeAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 36),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1733),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: _accent.withOpacity(0.25), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: _accent.withOpacity(0.4),
                                    width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  _avatarEmojis[_selectedAvatar],
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Welcome,",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nameController.text.trim(),
                              style: const TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}