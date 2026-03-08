import 'package:flutter/material.dart';
import 'selection1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color purpleDark   = Color(0xFF5B1F7A);
  static const Color purpleMid    = Color(0xFF7B2FA0);
  static const Color purpleAccent = Color(0xFF9B4FBF);
  static const Color bgColor      = Color(0xFFF4F1EE);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 600) {
      return _TabletLayout(
        usernameController: _usernameController,
        passwordController: _passwordController,
        purpleDark: purpleDark,
        purpleMid: purpleMid,
        purpleAccent: purpleAccent,
        bgColor: bgColor,
      );
    } else {
      return _MobileLayout(
        usernameController: _usernameController,
        passwordController: _passwordController,
        purpleDark: purpleDark,
        purpleMid: purpleMid,
        purpleAccent: purpleAccent,
        bgColor: bgColor,
      );
    }
  }
}

// =============================================================================
// TABLET LAYOUT  (>= 600dp)
// =============================================================================
class _TabletLayout extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final Color purpleDark, purpleMid, purpleAccent, bgColor;

  const _TabletLayout({
    required this.usernameController,
    required this.passwordController,
    required this.purpleDark,
    required this.purpleMid,
    required this.purpleAccent,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bgColor,
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 40),
                child: _LoginForm(
                  usernameController: usernameController,
                  passwordController: passwordController,
                  purpleDark: purpleDark,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: _PurplePanel(
              purpleDark: purpleDark,
              purpleMid: purpleMid,
              purpleAccent: purpleAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MOBILE LAYOUT  (< 600dp) — OVERFLOW FIXED
// =============================================================================
class _MobileLayout extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final Color purpleDark, purpleMid, purpleAccent, bgColor;

  const _MobileLayout({
    required this.usernameController,
    required this.passwordController,
    required this.purpleDark,
    required this.purpleMid,
    required this.purpleAccent,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // ✅ KEY FIX: allows scaffold to resize when keyboard appears
      resizeToAvoidBottomInset: true,
      backgroundColor: bgColor,
      // ✅ KEY FIX: entire page scrolls so nothing overflows
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Top — purple panel (fixed height, shrinks on small screens)
            SizedBox(
              height: screenHeight * 0.38,
              child: _PurplePanel(
                purpleDark: purpleDark,
                purpleMid: purpleMid,
                purpleAccent: purpleAccent,
              ),
            ),

            // Bottom — login form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: _LoginForm(
                usernameController: usernameController,
                passwordController: passwordController,
                purpleDark: purpleDark,
              ),
            ),

            // ✅ Extra bottom padding so content clears keyboard
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PURPLE PANEL
// =============================================================================
class _PurplePanel extends StatelessWidget {
  final Color purpleDark, purpleMid, purpleAccent;

  const _PurplePanel({
    required this.purpleDark,
    required this.purpleMid,
    required this.purpleAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [purpleDark, purpleMid, purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Blob — top right
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: const BorderRadius.only(
                topLeft:     Radius.circular(140),
                bottomLeft:  Radius.circular(110),
                bottomRight: Radius.circular(70),
              ),
            ),
          ),
        ),

        // Blob — bottom left
        Positioned(
          bottom: -50,
          left: -30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to\nStudent Portal',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/Images/login_img.png',
                  fit: BoxFit.contain,
                  height: 160,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// LOGIN FORM
// =============================================================================
class _LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final Color purpleDark;

  const _LoginForm({
    required this.usernameController,
    required this.passwordController,
    required this.purpleDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Login',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter your account details',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 30),

        _InputField(
          controller: usernameController,
          hint: 'Username',
          obscure: false,
          purpleDark: purpleDark,
        ),
        const SizedBox(height: 20),

        _InputField(
          controller: passwordController,
          hint: 'Password',
          obscure: true,
          purpleDark: purpleDark,
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: () {},
          child: const Text(
            'Forgot Password ?',
            style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
          ),
        ),
        const SizedBox(height: 36),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Selection1Page()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: purpleDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// REUSABLE TEXT FIELD
// =============================================================================
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Color purpleDark;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.purpleDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1.2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: purpleDark, width: 1.8),
        ),
      ),
    );
  }
}