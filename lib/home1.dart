import 'package:flutter/material.dart';
import 'chapter_page.dart';

class Home1Page extends StatefulWidget {
  const Home1Page({super.key});

  @override
  State<Home1Page> createState() => _Home1PageState();
}

class _Home1PageState extends State<Home1Page> {
  // Toggle: 0 = Study, 1 = Language
  int _toggleIndex = 0;
  int _bottomNavIndex = 0;

  static const Color purpleDark   = Color(0xFF5B1F7A);
  static const Color purpleMid    = Color(0xFF7B2FA0);
  static const Color purpleAccent = Color(0xFF9B4FBF);
  static const Color bgColor      = Color(0xFFF9F7FC);
  static const Color cardLight    = Color(0xFFCF9FE0);
  static const Color cardMid      = Color(0xFFB06FCC);

  final List<Map<String, dynamic>> _subjects = [
    {'name': 'Maths',     'icon': Icons.calculate_rounded},
    {'name': 'Science',   'icon': Icons.science_rounded},
    {'name': 'English',   'icon': Icons.menu_book_rounded},
    {'name': 'History',   'icon': Icons.account_balance_rounded},
    {'name': 'Geography', 'icon': Icons.public_rounded},
    {'name': 'Physics',   'icon': Icons.bolt_rounded},
    {'name': 'Chemistry', 'icon': Icons.biotech_rounded},
    {'name': 'Biology',   'icon': Icons.eco_rounded},
    {'name': 'Computer',  'icon': Icons.computer_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildToggle(),
                    const SizedBox(height: 24),
                    if (_toggleIndex == 0) _buildStudyContent(),
                    if (_toggleIndex == 1) _buildLanguagePlaceholder(),
                  ],
                ),
              ),
            ),

            // ── Bottom navigation ─────────────────────────────────────────
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Welcome Header ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        Text(
          'Student !',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  // ── Study / Language Toggle ────────────────────────────────────────────────
  Widget _buildToggle() {
    return Center(
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFEDD6F7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleButton(
              label: 'Study',
              isSelected: _toggleIndex == 0,
              purpleDark: purpleDark,
              onTap: () => setState(() => _toggleIndex = 0),
            ),
            _ToggleButton(
              label: 'Language',
              isSelected: _toggleIndex == 1,
              purpleDark: purpleDark,
              onTap: () => setState(() => _toggleIndex = 1),
            ),
          ],
        ),
      ),
    );
  }

  // ── Study Content ──────────────────────────────────────────────────────────
  Widget _buildStudyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Subjects'),
        const SizedBox(height: 14),
        _buildSubjectsGrid(),
        const SizedBox(height: 24),
        _buildStudyNotesBanner(),
        const SizedBox(height: 24),
        _SectionTitle(title: 'Continue Watching'),
        const SizedBox(height: 14),
        _buildContinueWatching(),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Subjects Grid ──────────────────────────────────────────────────────────
  Widget _buildSubjectsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return _SubjectCard(
          name: subject['name'],
          icon: subject['icon'],
          cardLight: cardLight,
          cardMid: cardMid,
          purpleDark: purpleDark,
          // ✅ Navigation added here
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChapterPage(subjectName: subject['name']),
              ),
            );
          },
        );
      },
    );
  }

  // ── Best Study Notes Banner ────────────────────────────────────────────────
  Widget _buildStudyNotesBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [purpleDark, purpleMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Best Study Notes',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Get best study notes\nfor every subject !',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Let's Explore",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: purpleDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _BannerIllustration(),
          ),
        ],
      ),
    );
  }

  // ── Continue Watching ──────────────────────────────────────────────────────
  Widget _buildContinueWatching() {
    return Row(
      children: [
        Expanded(child: _VideoCard()),
        const SizedBox(width: 14),
        Expanded(child: _VideoCard()),
      ],
    );
  }

  // ── Language Placeholder ───────────────────────────────────────────────────
  Widget _buildLanguagePlaceholder() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language_rounded, size: 64, color: purpleAccent.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Language Page\nComing Soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: purpleDark.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Navigation ──────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,        'label': 'Home'},
      {'icon': Icons.search_rounded,      'label': 'Search'},
      {'icon': Icons.access_time_rounded, 'label': 'History'},
      {'icon': Icons.person_rounded,      'label': 'Profile'},
      {'icon': Icons.settings_rounded,    'label': 'Settings'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final bool isActive = _bottomNavIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _bottomNavIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                items[index]['icon'] as IconData,
                size: 26,
                color: isActive ? const Color(0xFF5B1F7A) : const Color(0xFFBBBBBB),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// TOGGLE BUTTON
// =============================================================================
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color purpleDark;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.purpleDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? purpleDark : const Color(0xFF888888),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION TITLE
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
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF5B1F7A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SUBJECT CARD — now accepts onTap callback
// =============================================================================
class _SubjectCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color cardLight, cardMid, purpleDark;
  final VoidCallback onTap; // ✅ Added onTap parameter

  const _SubjectCard({
    required this.name,
    required this.icon,
    required this.cardLight,
    required this.cardMid,
    required this.purpleDark,
    required this.onTap, // ✅ Required
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ✅ Uses passed onTap
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cardLight, cardMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
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
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 5),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// BANNER ILLUSTRATION
// =============================================================================
class _BannerIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 10,
            bottom: 0,
            child: Container(
              width: 55,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white70, size: 50),
            ),
          ),
          Positioned(
            left: 0,
            top: 10,
            child: Icon(Icons.lightbulb_rounded, color: Colors.white.withOpacity(0.6), size: 20),
          ),
          Positioned(
            left: 20,
            top: 40,
            child: Icon(Icons.hourglass_bottom_rounded, color: Colors.white.withOpacity(0.5), size: 18),
          ),
          Positioned(
            left: 5,
            bottom: 20,
            child: Icon(Icons.sticky_note_2_rounded, color: Colors.white.withOpacity(0.5), size: 18),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// VIDEO CARD
// =============================================================================
class _VideoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E0F0),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: const Color(0xFFD1B8E8),
              child: const Icon(Icons.play_lesson_rounded, size: 40, color: Colors.white54),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF5B1F7A), size: 22),
          ),
        ],
      ),
    );
  }
}