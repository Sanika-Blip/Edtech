import 'package:flutter/material.dart';
import 'home1.dart';

class Selection2Page extends StatefulWidget {
  const Selection2Page({super.key});

  @override
  State<Selection2Page> createState() => _Selection2PageState();
}

class _Selection2PageState extends State<Selection2Page> {
  static const Color greenDark    = Color(0xFF388E3C);
  static const Color greenMid     = Color(0xFF66BB6A);
  static const Color greenLight   = Color(0xFFA5D6A7);
  static const Color bgColor      = Color(0xFFF1F8F1);

  String? _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {'name': 'Korean',   'flag': '🇰🇷'},
    {'name': 'Japanese', 'flag': '🇯🇵'},
    {'name': 'German',   'flag': '🇩🇪'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──────────────────────────────────────────────────────
            _SectionTitle(title: 'Select your Language'),
            const SizedBox(height: 24),

            // ── Language Cards ─────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final double cardSize = (constraints.maxWidth - 16) / 2;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _languages.map((lang) {
                    final bool isSelected = _selectedLanguage == lang['name'];
                    return _LanguageCard(
                      name: lang['name']!,
                      flag: lang['flag']!,
                      isSelected: isSelected,
                      cardSize: cardSize,
                      greenDark: greenDark,
                      greenMid: greenMid,
                      greenLight: greenLight,
                      onTap: () => setState(() => _selectedLanguage = lang['name']),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 48),

            // ── Continue Button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedLanguage != null
                    ? () {
                        Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const Home1Page()),
);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenDark,
                  disabledBackgroundColor: greenDark.withOpacity(0.35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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

// =============================================================================
// SECTION TITLE with green underline accent
// =============================================================================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: Color(0xFF388E3C),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// LANGUAGE CARD — green theme
// =============================================================================
class _LanguageCard extends StatelessWidget {
  final String name;
  final String flag;
  final bool isSelected;
  final double cardSize;
  final Color greenDark, greenMid, greenLight;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.name,
    required this.flag,
    required this.isSelected,
    required this.cardSize,
    required this.greenDark,
    required this.greenMid,
    required this.greenLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cardSize,
        height: cardSize * 0.75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [greenDark, greenMid]
                : [greenLight, const Color(0xFF81C784)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : Border.all(color: Colors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: greenDark.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 10),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            if (isSelected) const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}