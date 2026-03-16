import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'search_page.dart';
import 'home1.dart';
import 'history_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARED PALETTE (matches home1_page)
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFFF7F4FB);
  static const inkDark   = Color(0xFF3D3660);
  static const inkMid    = Color(0xFF6B6490);
  static const inkLight  = Color(0xFF9E9BBF);
  static const lavDark   = Color(0xFFB8A6D9);
  static const lavMid    = Color(0xFFC9B8E8);
  static const lavLight  = Color(0xFFEAE3F7);
  static const peachA    = Color(0xFFF9D9B8);
  static const peachB    = Color(0xFFF0C49A);
  static const mintA     = Color(0xFFB8E4D8);
  static const mintB     = Color(0xFF9DD4C5);
  static const blushA    = Color(0xFFF2C4CE);
  static const blushB    = Color(0xFFE8A8B5);
  static const skyA      = Color(0xFFB8D8F2);
  static const skyB      = Color(0xFF9DC8EA);
  static const lemonA    = Color(0xFFF2EDB8);
  static const lemonB    = Color(0xFFE8E09A);
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE PAGE
// ─────────────────────────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  int _bottomNavIndex = 3;

  late AnimationController _heroCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _statsCtrl;

  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _avatarPop;
  late Animation<double> _statsAnim;

  final List<Map<String, dynamic>> _completedCourses = [
    {
      'subject': 'Mathematics',
      'subtitle': 'Quadratic Equations',
      'emoji': '🔢',
      'c1': _C.skyA,
      'c2': _C.skyB,
      'progress': 1.0,
    },
    {
      'subject': 'Science',
      'subtitle': 'Photosynthesis',
      'emoji': '🧪',
      'c1': _C.mintA,
      'c2': _C.mintB,
      'progress': 1.0,
    },
  ];

  final List<Map<String, dynamic>> _performance = [
    {'subject': 'Mathematics', 'emoji': '🔢', 'percent': 0.87, 'c': _C.skyB},
    {'subject': 'Science',     'emoji': '🧪', 'percent': 0.72, 'c': _C.mintB},
    {'subject': 'English',     'emoji': '📖', 'percent': 0.65, 'c': _C.blushB},
    {'subject': 'History',     'emoji': '🏛️', 'percent': 0.80, 'c': _C.peachB},
  ];

  final List<Map<String, dynamic>> _achievements = [
    {'emoji': '🥇', 'label': 'Top Scorer',  'color': _C.lemonA},
    {'emoji': '🔥', 'label': '7-Day Streak','color': _C.peachA},
    {'emoji': '⭐', 'label': 'Star Student', 'color': _C.lavLight},
    {'emoji': '🏆', 'label': 'Champion',    'color': _C.mintA},
  ];

  final List<Map<String, dynamic>> _stats = [
    {'value': '42',  'label': 'Lessons',  'emoji': '📚'},
    {'value': '7',   'label': 'Streak',   'emoji': '🔥'},
    {'value': '87%', 'label': 'Accuracy', 'emoji': '🎯'},
  ];

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _avatarPop = CurvedAnimation(parent: _heroCtrl, curve: Curves.elasticOut);

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();

    _statsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _statsAnim = CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _statsCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _statsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildBgBlobs(),
                  ..._buildParticles(),
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeroHeader(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 18),
                              _buildStatsRow(),
                              const SizedBox(height: 22),
                              _buildAchievementsSection(),
                              const SizedBox(height: 22),
                              _buildSectionTitle('Completed Courses 🎓'),
                              const SizedBox(height: 14),
                              _buildCoursesRow(),
                              const SizedBox(height: 22),
                              _buildSectionTitle('Performance Overview 📊'),
                              const SizedBox(height: 14),
                              _buildPerformanceCard(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Background blobs ────────────────────────────────────────────────────
  Widget _buildBgBlobs() {
    return IgnorePointer(
      child: Stack(children: [
        Positioned(
          top: -40, right: -40,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.lavLight.withOpacity(0.55),
            ),
          ),
        ),
        Positioned(
          top: 260, left: -50,
          child: Container(
            width: 150, height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.mintA.withOpacity(0.35),
            ),
          ),
        ),
        Positioned(
          bottom: 100, right: -30,
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.peachA.withOpacity(0.35),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Floating particles ──────────────────────────────────────────────────
  List<Widget> _buildParticles() {
    final items = [
      {'e': '⭐', 'lf': 0.05, 'tf': 0.08, 'ph': 0.0},
      {'e': '✨', 'lf': 0.82, 'tf': 0.05, 'ph': 0.4},
      {'e': '🎀', 'lf': 0.87, 'tf': 0.20, 'ph': 0.9},
      {'e': '💫', 'lf': 0.03, 'tf': 0.35, 'ph': 0.7},
      {'e': '🌸', 'lf': 0.88, 'tf': 0.50, 'ph': 0.2},
    ];
    return items.map((item) {
      return AnimatedBuilder(
        animation: _floatCtrl,
        builder: (ctx, _) {
          final sw = MediaQuery.of(ctx).size.width;
          final t  = (_floatCtrl.value + (item['ph'] as double)) % 1.0;
          final dy = math.sin(t * math.pi) * 10.0;
          return Positioned(
            left: sw  * (item['lf'] as double),
            top: 700  * (item['tf'] as double) + dy,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.4,
                child: Text(item['e'] as String,
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  // ── Hero header ─────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    return FadeTransition(
      opacity: _heroFade,
      child: SlideTransition(
        position: _heroSlide,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC9B8E8), Color(0xFFEAD8F8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Decorative circles inside header
              Positioned(
                top: -20, right: -20,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
              Positioned(
                bottom: 10, left: -15,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    // Top row — greeting + bell
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '👤  My Profile',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _C.inkDark,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.45),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: _C.inkDark,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Avatar + name
                    ScaleTransition(
                      scale: _avatarPop,
                      child: Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [_C.lavDark, Color(0xFF9B7FD4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                              color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: _C.lavDark.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('SP',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1,
                              )),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Hey, Student! 👋',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _C.inkDark,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Class 10 · Science Stream',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.inkMid,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Badges row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _HeaderBadge(emoji: '🔥', label: '7 Day Streak'),
                        const SizedBox(width: 8),
                        _HeaderBadge(emoji: '🏆', label: '22,560 pts'),
                        const SizedBox(width: 8),
                        _HeaderBadge(emoji: '📚', label: '42 Lessons'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats row ───────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return AnimatedBuilder(
      animation: _statsAnim,
      builder: (_, __) {
        return Row(
          children: _stats.asMap().entries.map((e) {
            final i    = e.key;
            final stat = e.value;
            final delay = i * 0.15;
            final t = (_statsAnim.value - delay).clamp(0.0, 1.0);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < _stats.length - 1 ? 10 : 0),
                child: Transform.scale(
                  scale: Curves.easeOutBack.transform(t.clamp(0.0, 1.0)),
                  child: _StatCard(
                    value: stat['value'],
                    label: stat['label'],
                    emoji: stat['emoji'],
                    floatCtrl: _floatCtrl,
                    phaseOffset: i * 0.3,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── Achievements section ─────────────────────────────────────────────────
  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Achievements 🏅'),
        const SizedBox(height: 14),
        Row(
          children: _achievements.asMap().entries.map((e) {
            final i   = e.key;
            final ach = e.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < _achievements.length - 1 ? 10 : 0),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 500 + i * 100),
                  curve: Curves.easeOutBack,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: _AchievementBadge(
                    emoji: ach['emoji'],
                    label: ach['label'],
                    color: ach['color'],
                    floatCtrl: _floatCtrl,
                    phase: i * 0.25,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Courses row ──────────────────────────────────────────────────────────
  Widget _buildCoursesRow() {
    return Row(
      children: _completedCourses.asMap().entries.map((e) {
        final i      = e.key;
        final course = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 0 ? 10 : 0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 500 + i * 120),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) => Opacity(
                opacity: v,
                child: Transform.translate(
                    offset: Offset(0, 20 * (1 - v)), child: child),
              ),
              child: _CourseCard(course: course),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Performance card ────────────────────────────────────────────────────
  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _C.lavMid.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: _performance.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          return Padding(
            padding: EdgeInsets.only(bottom: i < _performance.length - 1 ? 18 : 0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: p['percent']),
              duration: Duration(milliseconds: 900 + i * 150),
              curve: Curves.easeOutCubic,
              builder: (_, val, __) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(p['emoji'],
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p['subject'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _C.inkDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: (p['c'] as Color).withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(val * 100).round()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: _C.inkDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: val,
                        minHeight: 10,
                        backgroundColor: _C.lavLight,
                        valueColor: AlwaysStoppedAnimation<Color>(p['c']),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section title ────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _C.inkDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 50, height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_C.lavDark, _C.lavLight]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav (matches home1_page.dart exactly) ─────────────────────────
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
            color: _C.lavMid.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = _bottomNavIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Home1Page()),
                  (route) => false,
                );
              } else if (index == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchPage()));
              } else if (index == 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()));
              } else {
                setState(() => _bottomNavIndex = index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _C.lavLight : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.22 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      items[index]['icon'] as IconData,
                      size: 24,
                      color: isActive ? _C.inkDark : _C.inkLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isActive ? _C.inkDark : _C.inkLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// HEADER BADGE
// =============================================================================
class _HeaderBadge extends StatelessWidget {
  final String emoji;
  final String label;
  const _HeaderBadge({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _C.inkDark,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// STAT CARD  (animated float)
// =============================================================================
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  final AnimationController floatCtrl;
  final double phaseOffset;

  const _StatCard({
    required this.value,
    required this.label,
    required this.emoji,
    required this.floatCtrl,
    required this.phaseOffset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatCtrl,
      builder: (_, child) {
        final t  = (floatCtrl.value + phaseOffset) % 1.0;
        final dy = math.sin(t * math.pi) * 4;
        return Transform.translate(
          offset: Offset(0, -dy),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _C.lavMid.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _C.inkDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _C.inkLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ACHIEVEMENT BADGE
// =============================================================================
class _AchievementBadge extends StatefulWidget {
  final String emoji;
  final String label;
  final Color color;
  final AnimationController floatCtrl;
  final double phase;

  const _AchievementBadge({
    required this.emoji,
    required this.label,
    required this.color,
    required this.floatCtrl,
    required this.phase,
  });

  @override
  State<_AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<_AchievementBadge> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.floatCtrl,
      builder: (_, child) {
        final t  = (widget.floatCtrl.value + widget.phase) % 1.0;
        final dy = math.sin(t * math.pi) * 5;
        return Transform.translate(
          offset: Offset(0, -dy),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _C.inkDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// COURSE CARD
// =============================================================================
class _CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  const _CourseCard({required this.course});

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (course['c2'] as Color).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with emoji
              Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [course['c1'], course['c2']],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(course['emoji'],
                      style: const TextStyle(fontSize: 36)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['subject'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _C.inkDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course['subtitle'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: _C.inkLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar (full = completed)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: course['progress'],
                        minHeight: 6,
                        backgroundColor: _C.lavLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            course['c2']),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: _C.lavLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _C.lavMid, width: 1),
                            ),
                            child: const Center(
                              child: Text(
                                'Report',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _C.inkDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: _C.inkDark,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Learn 🚀',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
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
        ),
      ),
    );
  }
}