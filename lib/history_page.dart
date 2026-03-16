import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'search_page.dart';
import 'home1.dart';
import 'profile_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARED PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const bg       = Color(0xFFF7F4FB);
  static const inkDark  = Color(0xFF3D3660);
  static const inkMid   = Color(0xFF6B6490);
  static const inkLight = Color(0xFF9E9BBF);
  static const lavDark  = Color(0xFFB8A6D9);
  static const lavMid   = Color(0xFFC9B8E8);
  static const lavLight = Color(0xFFEAE3F7);
  static const peachA   = Color(0xFFF9D9B8);
  static const peachB   = Color(0xFFF0C49A);
  static const mintA    = Color(0xFFB8E4D8);
  static const mintB    = Color(0xFF9DD4C5);
  static const blushA   = Color(0xFFF2C4CE);
  static const blushB   = Color(0xFFE8A8B5);
  static const skyA     = Color(0xFFB8D8F2);
  static const skyB     = Color(0xFF9DC8EA);
  static const lemonA   = Color(0xFFF2EDB8);
  static const lemonB   = Color(0xFFE8E09A);
  static const lilacA   = Color(0xFFD8B8F2);
  static const lilacB   = Color(0xFFC8A0E8);
  static const sagA     = Color(0xFFC8DFC4);
  static const sagB     = Color(0xFFB0CCA8);
  static const powderA  = Color(0xFFC4D8F0);
  static const powderB  = Color(0xFFACC4E4);
}

// Subject → color + emoji lookup
Map<String, Map<String, dynamic>> _subjectMeta = {
  'Maths':     {'c1': _C.lavMid,  'c2': _C.lavDark, 'e': '🔢'},
  'Science':   {'c1': _C.mintA,   'c2': _C.mintB,   'e': '🧪'},
  'English':   {'c1': _C.blushA,  'c2': _C.blushB,  'e': '📖'},
  'History':   {'c1': _C.skyA,    'c2': _C.skyB,    'e': '🏛️'},
  'Geography': {'c1': _C.peachA,  'c2': _C.peachB,  'e': '🌍'},
  'Physics':   {'c1': _C.lemonA,  'c2': _C.lemonB,  'e': '⚡'},
  'Chemistry': {'c1': _C.lilacA,  'c2': _C.lilacB,  'e': '🧬'},
  'Biology':   {'c1': _C.sagA,    'c2': _C.sagB,    'e': '🌿'},
  'Computer':  {'c1': _C.powderA, 'c2': _C.powderB, 'e': '💻'},
};

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY PAGE
// ─────────────────────────────────────────────────────────────────────────────
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  int _bottomNavIndex = 2;
  int _tabIndex       = 0;

  late AnimationController _headerCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _todayHistory = [
    {'subject': 'Maths',   'topic': 'Topic 6', 'chapter': 'Algebra Basics',    'duration': '12 min'},
    {'subject': 'Science', 'topic': 'Topic 6', 'chapter': 'Photosynthesis',     'duration': '18 min'},
    {'subject': 'English', 'topic': 'Topic 6', 'chapter': 'Grammar Essentials', 'duration': '9 min'},
  ];

  final List<Map<String, dynamic>> _last7DaysHistory = [
    {'subject': 'History',   'topic': 'Topic 6', 'chapter': 'World War II',   'duration': '22 min'},
    {'subject': 'Physics',   'topic': 'Topic 6', 'chapter': "Newton's Laws",  'duration': '15 min'},
    {'subject': 'Chemistry', 'topic': 'Topic 6', 'chapter': 'Periodic Table', 'duration': '20 min'},
  ];

  final List<Map<String, dynamic>> _watchLater = [
    {'subject': 'Biology',   'topic': 'Topic 3', 'chapter': 'Cell Structure',  'duration': '14 min'},
    {'subject': 'Computer',  'topic': 'Topic 5', 'chapter': 'Data Structures', 'duration': '25 min'},
    {'subject': 'Geography', 'topic': 'Topic 2', 'chapter': 'Plate Tectonics', 'duration': '17 min'},
    {'subject': 'Maths',     'topic': 'Topic 8', 'chapter': 'Trigonometry',    'duration': '19 min'},
  ];

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _headerCtrl, curve: Curves.easeOutCubic));

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
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
                  Column(
                    children: [
                      _buildTopBar(),
                      _buildToggle(),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.04, 0),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: SingleChildScrollView(
                            key: ValueKey(_tabIndex),
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            child: _tabIndex == 0
                                ? _buildWatchHistory()
                                : _buildWatchLater(),
                          ),
                        ),
                      ),
                    ],
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
          top: -50, right: -50,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.lavLight.withOpacity(0.55),
            ),
          ),
        ),
        Positioned(
          top: 240, left: -50,
          child: Container(
            width: 150, height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.mintA.withOpacity(0.35),
            ),
          ),
        ),
        Positioned(
          bottom: 80, right: -30,
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.peachA.withOpacity(0.3),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Floating particles ──────────────────────────────────────────────────
  List<Widget> _buildParticles() {
    final items = [
      {'e': '📺', 'lf': 0.05, 'tf': 0.08, 'ph': 0.0},
      {'e': '⏰', 'lf': 0.82, 'tf': 0.06, 'ph': 0.5},
      {'e': '🎬', 'lf': 0.87, 'tf': 0.25, 'ph': 1.0},
      {'e': '🔖', 'lf': 0.04, 'tf': 0.42, 'ph': 0.7},
      {'e': '🌸', 'lf': 0.86, 'tf': 0.55, 'ph': 0.3},
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
            top: 680  * (item['tf'] as double) + dy,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.38,
                child: Text(item['e'] as String,
                    style: const TextStyle(fontSize: 17)),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  // ── Top bar ─────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC9B8E8), Color(0xFFEAD8F8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            children: [
              // Back + title row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: _C.inkDark, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'My History  🕐',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _C.inkDark,
                    ),
                  ),
                  const Spacer(),
                  // Search shortcut
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SearchPage())),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search_rounded,
                          color: _C.inkDark, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Stats pills
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatPill(emoji: '📺', label: '6 Videos', color: _C.lavLight),
                  const SizedBox(width: 10),
                  _StatPill(emoji: '🔖', label: '4 Saved',  color: _C.peachA),
                  const SizedBox(width: 10),
                  _StatPill(emoji: '⏱️', label: '96 min',   color: _C.mintA),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Toggle ───────────────────────────────────────────────────────────────
  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 + (_pulseCtrl.value - 0.5).abs() * 0.004,
          child: child,
        ),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: _C.lavLight,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _C.lavMid.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _ToggleBtn(
                label: 'Watch History',
                emoji: '📺',
                selected: _tabIndex == 0,
                onTap: () => setState(() => _tabIndex = 0),
              ),
              _ToggleBtn(
                label: 'Watch Later',
                emoji: '🔖',
                selected: _tabIndex == 1,
                onTap: () => setState(() => _tabIndex = 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Watch History ────────────────────────────────────────────────────────
  Widget _buildWatchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Today 🌤️'),
        const SizedBox(height: 14),
        ..._todayHistory.asMap().entries.map((e) =>
            _buildVideoCard(e.value, e.key, isWatchLater: false)),
        const SizedBox(height: 24),
        _buildSectionTitle('Last 7 Days 📅'),
        const SizedBox(height: 14),
        ..._last7DaysHistory.asMap().entries.map((e) =>
            _buildVideoCard(e.value, e.key + 3, isWatchLater: false)),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Watch Later ──────────────────────────────────────────────────────────
  Widget _buildWatchLater() {
    if (_watchLater.isEmpty) {
      return SizedBox(
        height: 340,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                      0, math.sin(_floatCtrl.value * math.pi) * 8),
                  child: child,
                ),
                child: const Text('🔖',
                    style: TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nothing saved yet!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _C.inkDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap bookmark on any video to save it 📌',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _C.inkLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Saved Videos 🔖'),
        const SizedBox(height: 14),
        ..._watchLater.asMap().entries.map((e) =>
            _buildVideoCard(e.value, e.key, isWatchLater: true)),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Video card ───────────────────────────────────────────────────────────
  Widget _buildVideoCard(Map<String, dynamic> item, int index,
      {required bool isWatchLater}) {
    final meta = _subjectMeta[item['subject']] ??
        {'c1': _C.lavMid, 'c2': _C.lavDark, 'e': '📚'};
    final c1    = meta['c1'] as Color;
    final c2    = meta['c2'] as Color;
    final emoji = meta['e'] as String;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 380 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
      ),
      child: _VideoCard(
        item: item,
        emoji: emoji,
        c1: c1,
        c2: c2,
        isWatchLater: isWatchLater,
        floatCtrl: _floatCtrl,
        phase: index * 0.18,
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
        const SizedBox(height: 2),
      ],
    );
  }

  // ── Bottom Nav (identical to home1_page.dart) ────────────────────────────
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
              } else if (index == 3) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()));
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
// TOGGLE BUTTON (reuses same pattern as home1_page)
// =============================================================================
class _ToggleBtn extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleBtn({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: selected
                ? [BoxShadow(
                    color: _C.lavMid.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected ? _C.inkDark : _C.inkLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// STAT PILL  (header badges)
// =============================================================================
class _StatPill extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  const _StatPill({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
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
// VIDEO CARD
// =============================================================================
class _VideoCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final String emoji;
  final Color c1;
  final Color c2;
  final bool isWatchLater;
  final AnimationController floatCtrl;
  final double phase;

  const _VideoCard({
    required this.item,
    required this.emoji,
    required this.c1,
    required this.c2,
    required this.isWatchLater,
    required this.floatCtrl,
    required this.phase,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.c2.withOpacity(0.35),
                  blurRadius: _pressed ? 4 : 12,
                  offset: Offset(0, _pressed ? 2 : 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // ── Color thumbnail ──────────────────────────────────
                Container(
                  width: 72,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.c1, widget.c2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Floating emoji
                      AnimatedBuilder(
                        animation: widget.floatCtrl,
                        builder: (_, child) {
                          final t  = (widget.floatCtrl.value + widget.phase) % 1.0;
                          final dy = math.sin(t * math.pi) * 4;
                          return Transform.translate(
                              offset: Offset(0, -dy), child: child);
                        },
                        child: Text(widget.emoji,
                            style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(height: 5),
                      // Play button
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: _C.inkDark, size: 14),
                      ),
                    ],
                  ),
                ),

                // ── Info ────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Topic chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.c1.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.item['topic'],
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _C.inkDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.item['chapter'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _C.inkDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              widget.item['subject'],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _C.inkMid,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3, height: 3,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _C.inkLight,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.item['duration'],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _C.inkLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Action button ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: widget.c1.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isWatchLater
                          ? Icons.bookmark_remove_rounded
                          : Icons.play_circle_outline_rounded,
                      color: _C.inkDark,
                      size: 18,
                    ),
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