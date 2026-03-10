import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herodydemo/screens/login.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  final emailController = TextEditingController();

  static const Color _accent = Color(0xFF7B61FF);
  static const Color _bgTop = Color(0xFF0F0C29);
  static const Color _bgBottom = Color(0xFF302B63);
  static const Color _cardBg = Color(0xFF1A1733);

  bool _isLoading = false;
  bool _emailFocused = false;
  String _userName = '';
  String _userAvatar = '🦊';

  final FocusNode _emailFocus = FocusNode();

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
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
            begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryController, curve: Curves.easeOutCubic));

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _entryController.forward();
    _emailFocus.addListener(
        () => setState(() => _emailFocused = _emailFocus.hasFocus));
    _loadProfile();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _emailFocus.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        emailController.text = doc.data()?["email"] ?? "";
        _userName = doc.data()?["name"] ?? user!.displayName ?? "";
        _userAvatar = doc.data()?["avatar"] ?? '🦊';
      });
    }
  }

  Future<void> _saveEmail() async {
    if (user == null) return;
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .set({"email": emailController.text}, SetOptions(merge: true));
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Email saved",
            style: TextStyle(fontFamily: 'Outfit')),
        backgroundColor: _cardBg,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _logout() async {

  await FirebaseAuth.instance.signOut();

  if (mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

}

  void _showLogoutDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: const Color(0xFFFF6B6B).withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    blurRadius: 40)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Color(0xFFFF6B6B), size: 24),
                ),
                const SizedBox(height: 16),
                const Text("Sign Out?",
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                const SizedBox(height: 8),
                Text("You'll need to verify your phone\nnumber to sign back in.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.4),
                      height: 1.5,
                    )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Center(
                            child: Text("Cancel",
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color:
                                        Colors.white.withOpacity(0.5))),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _logout();
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFFFF6B6B)
                                      .withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6))
                            ],
                          ),
                          child: const Center(
                            child: Text("Sign Out",
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgTop,
      body: Container(
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
              top: -90,
              right: -70,
              child: ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withOpacity(0.07),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6B6B).withOpacity(0.04),
                ),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top bar ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Row(
                          children: [
                            GestureDetector(
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
                                    size: 16),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                "My Profile",
                                style: TextStyle(
                                  fontFamily: 'Playfair Display',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _accent.withOpacity(0.3),
                                    width: 1),
                              ),
                              child: Text(
                                "Account",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _accent,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Avatar card ────────────────────────────
                      SlideTransition(
                        position: _slideAnim,
                        child: Center(
                          child: Column(
                            children: [
                              // Avatar circle
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: _accent.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _accent.withOpacity(0.4),
                                      width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                        color: _accent.withOpacity(0.2),
                                        blurRadius: 24,
                                        spreadRadius: 2)
                                  ],
                                ),
                                child: Center(
                                  child: Text(_userAvatar,
                                      style: const TextStyle(fontSize: 38)),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Name
                              Text(
                                _userName.isEmpty ? "Loading…" : _userName,
                                style: const TextStyle(
                                  fontFamily: 'Playfair Display',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Phone
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone_rounded,
                                      size: 13,
                                      color: Colors.white.withOpacity(0.4)),
                                  const SizedBox(width: 6),
                                  Text(
                                    user?.phoneNumber ?? "—",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.45),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Stats row
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 48),
                                child: StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(user?.uid)
                                      .snapshots(),
                                  builder: (ctx, snap) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _StatBadge(
                                            label: "Member",
                                            value: "Pro",
                                            accent: _accent),
                                        Container(
                                            width: 1,
                                            height: 32,
                                            color: Colors.white
                                                .withOpacity(0.08)),
                                        _StatBadge(
                                            label: "Status",
                                            value: "Active",
                                            accent: const Color(0xFF00D9C0)),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Email section ──────────────────────────
                      SlideTransition(
                        position: _slideAnim,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel("REMINDER EMAIL"),
                              const SizedBox(height: 12),

                              AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _emailFocused
                                        ? _accent.withOpacity(0.6)
                                        : Colors.white.withOpacity(0.1),
                                    width: _emailFocused ? 1.5 : 1,
                                  ),
                                  boxShadow: _emailFocused
                                      ? [
                                          BoxShadow(
                                              color:
                                                  _accent.withOpacity(0.1),
                                              blurRadius: 20,
                                              spreadRadius: 2)
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16),
                                      child: Icon(
                                        Icons.mail_outline_rounded,
                                        size: 18,
                                        color: _emailFocused
                                            ? _accent
                                            : Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: emailController,
                                        focusNode: _emailFocus,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "you@example.com",
                                          hintStyle: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 15,
                                            color: Colors.white
                                                .withOpacity(0.2),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              GestureDetector(
                                onTap: _saveEmail,
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: _accent,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                          color: _accent.withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8))
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.white),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Save Email",
                                                style: TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: Colors.white,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 26,
                                                height: 26,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8),
                                                ),
                                                child: const Icon(
                                                    Icons.check_rounded,
                                                    color: Colors.white,
                                                    size: 14),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Settings section ───────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: _SectionLabel("SETTINGS"),
                      ),

                      const SizedBox(height: 12),

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.07)),
                          ),
                          child: Column(
                            children: [
                              _SettingsTile(
                                icon: Icons.privacy_tip_rounded,
                                iconColor: _accent,
                                label: "Privacy Policy",
                                onTap: () {},
                                showDivider: true,
                              ),
                              _SettingsTile(
                                icon: Icons.contact_mail_rounded,
                                iconColor: const Color(0xFF00D9C0),
                                label: "Contact Us",
                                onTap: () {},
                                showDivider: true,
                              ),
                              _SettingsTile(
                                icon: Icons.info_outline_rounded,
                                iconColor:
                                    Colors.white.withOpacity(0.4),
                                label: "About",
                                onTap: () {},
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Logout tile
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: GestureDetector(
                          onTap: _showLogoutDialog,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B)
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFFF6B6B)
                                      .withOpacity(0.2)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B)
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                        Icons.logout_rounded,
                                        color: Color(0xFFFF6B6B),
                                        size: 18),
                                  ),
                                  const SizedBox(width: 14),
                                  const Text(
                                    "Sign Out",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFF6B6B),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.chevron_right_rounded,
                                      color: const Color(0xFFFF6B6B)
                                          .withOpacity(0.5),
                                      size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Footer
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _accent.withOpacity(0.2)),
                              ),
                              child: Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _accent,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Developed by Dhanush",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "v1.0.0",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.35),
        letterSpacing: 2.0,
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatBadge(
      {required this.label, required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 11,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.2), size: 18),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
              height: 1,
              color: Colors.white.withOpacity(0.06),
              indent: 66,
              endIndent: 16),
      ],
    );
  }
}