import 'package:flutter/material.dart';
import 'search_page.dart';
import 'home1.dart';
import 'history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _bottomNavIndex = 3;

  static const Color purpleDark  = Color(0xFF5B1F7A);
  static const Color purpleMid   = Color(0xFF7B2FA0);
  static const Color purpleLight = Color(0xFFCF9FE0);
  static const Color purplePale  = Color(0xFFF3E8FC);
  static const Color bgColor     = Color(0xFFF9F7FC);

  final List<Map<String, dynamic>> _completedCourses = [
    {
      'subject': 'Mathematics',
      'subtitle': 'Quadratic Linear Equations',
      'color1': Color(0xFF8EAFD4),
      'color2': Color(0xFFB8CDE8),
    },
    {
      'subject': 'Mathematics',
      'subtitle': 'Quadratic Linear Equations',
      'color1': Color(0xFF8EAFD4),
      'color2': Color(0xFFB8CDE8),
    },
  ];

  final List<Map<String, dynamic>> _performance = [
    {'subject': 'Mathematics', 'percent': 0.87, 'label': '87 %'},
    {'subject': 'Science',     'percent': 0.72, 'label': '72 %'},
    {'subject': 'English',     'percent': 0.65, 'label': '65 %'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Row 1: Overall Progress + Reward Points ─────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildProgressCard()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildRewardCard()),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Row 2: Achievements (full width) ────────────────────
                  _buildAchievementsCard(),
                  const SizedBox(height: 24),

                  // ── Completed Course header ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Completed Course',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A2E),
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: purpleMid,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'View all',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Course Cards Row ────────────────────────────────────
                  Row(
                    children: _completedCourses.asMap().entries.map((entry) {
                      final i = entry.key;
                      final course = entry.value;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i == 0 ? 10 : 0),
                          child: _buildCourseCard(course),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Performance Overview (full width) ───────────────────
                  _buildPerformanceCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [purpleDark, purpleMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: purpleLight,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: const Center(
              child: Text(
                'SP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name — ✅ Expanded prevents text overflow
          const Expanded(
            child: Text(
              'Hello, Student',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),

          // Learning streak — ✅ fixed width to prevent overflow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🔥', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
                Text(
                  'Learning streak',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Bell icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ── Overall Progress Card ─────────────────────────────────────────────────
  Widget _buildProgressCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [purpleDark, purpleMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: purpleDark.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Circular progress
          Center(
            child: SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 0.75,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '75 %',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Complete',
                        style:
                            TextStyle(fontSize: 8, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bar chart — fixed height, no overflow
          SizedBox(
            height: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _MiniBar(height: 10, color: Colors.red.shade300),
                _MiniBar(height: 16, color: Colors.orange.shade300),
                _MiniBar(height: 12, color: Colors.yellow.shade300),
                _MiniBar(height: 22, color: Colors.green.shade300),
                _MiniBar(height: 8,  color: Colors.blue.shade300),
                _MiniBar(height: 14, color: Colors.purple.shade200),
                _MiniBar(height: 6,  color: Colors.pink.shade200),
              ],
            ),
          ),

          const SizedBox(height: 6),
          const Text(
            'Study time this week.',
            style: TextStyle(fontSize: 8, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  // ── Reward Points Card ────────────────────────────────────────────────────
  Widget _buildRewardCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🏆', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Reward Points',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '22560',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '440 points to next achievement',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF856404),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Achievements Card (full width) ────────────────────────────────────────
  Widget _buildAchievementsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          const Text(
            'Achievements',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const Spacer(),
          const Text('🥇', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 16),
          const Text('🥇', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 16),
          const Text('🥇', style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }

  // ── Course Card ───────────────────────────────────────────────────────────
  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [course['color1'], course['color2']],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['subject'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  course['subtitle'],
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: purplePale,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: purpleLight, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              'View Report',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: purpleDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: purpleMid,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Learn',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Performance Overview Card (full width) ────────────────────────────────
  Widget _buildPerformanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 18),
          ..._performance.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p['subject'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        p['label'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: purpleDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: p['percent'],
                      minHeight: 9,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        p['percent'] >= 0.8
                            ? Colors.blue.shade400
                            : purpleMid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      Icons.home_rounded,
      Icons.search_rounded,
      Icons.access_time_rounded,
      Icons.person_rounded,
      Icons.settings_rounded,
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
        children: List.generate(items.length, (i) {
          final bool active = _bottomNavIndex == i;
          return GestureDetector(
            onTap: () {
              if (i == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Home1Page()),
                  (route) => false,
                );
              } else if (i == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                );
              } else if (i == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                );
              } else {
                setState(() => _bottomNavIndex = i);
              }
            },
            child: Icon(
              items[i],
              size: 26,
              color: active ? purpleDark : const Color(0xFFBBBBBB),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// MINI BAR
// =============================================================================
class _MiniBar extends StatelessWidget {
  final double height;
  final Color color;
  const _MiniBar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}