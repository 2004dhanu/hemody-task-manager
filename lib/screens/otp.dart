import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:herodydemo/screens/name.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  OtpScreen({required this.phone});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String verificationId = "";
  bool _isLoading = false;
  bool _isSending = true;
  int _resendSeconds = 30;
  bool _hasError = false;
  String _errorMsg = "";

  static const Color _accent = Color(0xFF7B61FF);
  static const Color _bgTop = Color(0xFF0F0C29);
  static const Color _bgBottom = Color(0xFF302B63);

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: -8.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: -8.0, end: 8.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: 8.0, end: -8.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: -8.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
    ]).animate(_shakeController);

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _entryController.forward();
    verifyPhone();
    _startResendTimer();

    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() => setState(() {}));
    }
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSeconds > 0) _resendSeconds--;
      });
      return _resendSeconds > 0;
    });
  }

  Future<void> verifyPhone() async {
    setState(() => _isSending = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phone.startsWith('+')
          ? widget.phone
          : "+91${widget.phone}",
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() {
            _isSending = false;
            _hasError = true;
            _errorMsg = e.message ?? "Verification failed";
          });
        }
      },
      codeSent: (String id, int? token) {
        if (mounted) {
          setState(() {
            verificationId = id;
            _isSending = false;
          });
        }
      },
      codeAutoRetrievalTimeout: (id) {
        verificationId = id;
      },
    );
  }

  String get _enteredOtp =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete => _enteredOtp.length == 6;

  Future<void> verifyOtp() async {
    if (!_isComplete) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: _enteredOtp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CreateProfileScreen()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMsg = "Invalid code. Please try again.";
      });
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      _shakeController.forward(from: 0);
    }
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _hasError = false);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
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
            // Orbs
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

            SafeArea(
              child: SingleChildScrollView(
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

                    const SizedBox(height: 48),

                    // Header
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
                                "Verification",
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
                                    text: "Check your\n",
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
                                    text: "Messages",
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

                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withOpacity(0.5),
                                  height: 1.6,
                                ),
                                children: [
                                  const TextSpan(
                                      text: "We sent a 6-digit code to "),
                                  TextSpan(
                                    text: widget.phone,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 52),

                    // OTP boxes
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ENTER CODE",
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.35),
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 14),

                          AnimatedBuilder(
                            animation: _shakeAnim,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(_shakeAnim.value, 0.0),
                              child: child,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (i) => _OtpBox(
                                controller: _controllers[i],
                                focusNode: _focusNodes[i],
                                isFocused: _focusNodes[i].hasFocus,
                                hasError: _hasError,
                                hasValue: _controllers[i].text.isNotEmpty,
                                accent: _accent,
                                onChanged: (v) => _onOtpDigitChanged(v, i),
                              )),
                            ),
                          ),

                          // Error message
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _hasError
                                ? Padding(
                                    key: const ValueKey('error'),
                                    padding: const EdgeInsets.only(top: 12, left: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          color: Color(0xFFFF6B6B),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _errorMsg,
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 13,
                                            color: Color(0xFFFF6B6B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(key: ValueKey('no_error'), height: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 44),

                    // Verify button
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: GestureDetector(
                        onTap: (_isComplete && !_isLoading) ? verifyOtp : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 62,
                          decoration: BoxDecoration(
                            color: _isComplete
                                ? _accent
                                : _accent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _isComplete
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
                                        "Verify & Continue",
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: _isComplete
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.4),
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _isComplete
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.06),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          color: _isComplete
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

                    // Resend row
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Center(
                        child: _resendSeconds > 0
                            ? RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.35),
                                  ),
                                  children: [
                                    const TextSpan(
                                        text: "Resend code in "),
                                    TextSpan(
                                      text: "${_resendSeconds}s",
                                      style: TextStyle(
                                        color: _accent.withOpacity(0.8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() => _resendSeconds = 30);
                                  verifyPhone();
                                  _startResendTimer();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: _accent.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    "Resend Code",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _accent,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Sending overlay
            if (_isSending)
              Container(
                color: Colors.black.withOpacity(0.55),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1733),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _accent.withOpacity(0.2), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                const AlwaysStoppedAnimation(_accent),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Sending OTP…",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
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

// ── OTP single box ─────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool hasError;
  final bool hasValue;
  final Color accent;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.hasError,
    required this.hasValue,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    if (hasError) {
      borderColor = const Color(0xFFFF6B6B).withOpacity(0.7);
    } else if (isFocused) {
      borderColor = accent.withOpacity(0.7);
    } else if (hasValue) {
      borderColor = accent.withOpacity(0.35);
    } else {
      borderColor = Colors.white.withOpacity(0.1);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 46,
      height: 58,
      decoration: BoxDecoration(
        color: hasValue
            ? accent.withOpacity(0.1)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isFocused ? 1.5 : 1),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: hasError ? const Color(0xFFFF6B6B) : Colors.white,
          letterSpacing: 0,
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}