import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'language_topic_detail_page.dart';
import 'search_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GREEN PASTEL PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class _LG {
  static const bg        = Color(0xFFF2FAF6);
  static const inkDark   = Color(0xFF2D6B4F);
  static const inkMid    = Color(0xFF4E9070);
  static const inkLight  = Color(0xFF88BBA0);

  static const gDark     = Color(0xFF4A8C6F);
  static const gMid      = Color(0xFF72B89A);
  static const gLight    = Color(0xFFB8E4D0);
  static const gPale     = Color(0xFFE4F5EE);

  // Node accent shades — all green family
  static const node1A    = Color(0xFFB8E4D0); // mint
  static const node1B    = Color(0xFF9DD4B8);
  static const node2A    = Color(0xFFC8ECD8); // sage
  static const node2B    = Color(0xFFADD8C0);
  static const node3A    = Color(0xFF9DCFB4); // teal
  static const node3B    = Color(0xFF7BBFA0);
  static const node4A    = Color(0xFF80C4A8); // deep mint
  static const node4B    = Color(0xFF60AA8C);
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA TYPES  (reuse shapes, new colour values)
// ─────────────────────────────────────────────────────────────────────────────
class _LTopicData {
  final String label, emoji;
  final bool   locked;
  final double dx, dy;
  final Color  c1, c2;
  const _LTopicData({
    required this.label, required this.emoji,
    required this.locked, required this.dx, required this.dy,
    required this.c1,    required this.c2,
  });
}

class _LFloatItem {
  final String emoji;
  final double dx, dy, phase;
  const _LFloatItem(this.emoji, this.dx, this.dy, this.phase);
}

// ─────────────────────────────────────────────────────────────────────────────
// LANGUAGE TOPIC MAP PAGE
// ─────────────────────────────────────────────────────────────────────────────
class LanguageTopicMapPage extends StatefulWidget {
  final String chapterTitle;
  const LanguageTopicMapPage({super.key, required this.chapterTitle});

  @override
  State<LanguageTopicMapPage> createState() => _LanguageTopicMapPageState();
}

class _LanguageTopicMapPageState extends State<LanguageTopicMapPage>
    with TickerProviderStateMixin {
  int _bottomNavIndex = 0;

  // ── Controllers ──────────────────────────────────────────────────────────
  late AnimationController _entranceCtrl;
  late AnimationController _pathCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _orbitCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _headerCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _pathProgress;
  late Animation<double> _pulseScale;
  late Animation<double> _orbitAngle;

  // ── Topic data (green palette, language emojis) ───────────────────────────
  static const List<_LTopicData> _topics = [
    _LTopicData(label: 'Lesson 1', emoji: '🌱', locked: false,
        dx: 0.14, dy: 0.75, c1: _LG.node1A, c2: _LG.node1B),
    _LTopicData(label: 'Lesson 2', emoji: '📖', locked: true,
        dx: 0.42, dy: 0.54, c1: _LG.node2A, c2: _LG.node2B),
    _LTopicData(label: 'Lesson 3', emoji: '✍️', locked: true,
        dx: 0.65, dy: 0.32, c1: _LG.node3A, c2: _LG.node3B),
    _LTopicData(label: 'Lesson 4', emoji: '🏆', locked: true,
        dx: 0.80, dy: 0.13, c1: _LG.node4A, c2: _LG.node4B),
  ];

  static const List<List<int>> _connections = [[0,1],[1,2],[2,3]];

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _headerCtrl, curve: Curves.easeOutCubic));

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    _pathCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pathProgress =
        CurvedAnimation(parent: _pathCtrl, curve: Curves.easeInOut);

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.94, end: 1.06).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _orbitAngle = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_orbitCtrl);

    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceCtrl.forward();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _pathCtrl.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pathCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _orbitCtrl.dispose();
    _shimmerCtrl.dispose();
    _headerCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq          = MediaQuery.of(context);
    final double sw   = mq.size.width;
    final double sh   = mq.size.height;
    const double navH    = 68.0;
    const double appBarH = 72.0;
    final double mapH = sh - mq.padding.top - appBarH - navH;

    return Scaffold(
      backgroundColor: _LG.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Animated app bar
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: _buildAppBar(),
              ),
            ),

            // Map canvas
            Expanded(
              child: SizedBox(
                width: sw,
                height: mapH,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // 1 — Animated green background
                    Positioned.fill(
                        child: _LAnimatedBg(floatCtrl: _floatCtrl)),

                    // 2 — Path lines
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_pathProgress, _shimmerCtrl]),
                        builder: (_, __) => CustomPaint(
                          painter: _LPathPainter(
                            topics:      _topics,
                            connections: _connections,
                            mapW:        sw,
                            mapH:        mapH,
                            progress:    _pathProgress.value,
                            shimmerT:    _shimmerCtrl.value,
                          ),
                        ),
                      ),
                    ),

                    // 3 — Overview node
                    _buildOverviewNode(sw, mapH),

                    // 4 — Topic nodes
                    ..._topics.asMap().entries.map((e) =>
                        _buildTopicNode(e.value, e.key, sw, mapH)),

                    // 5 — Orbit sparkles around locked nodes
                    ..._buildOrbitSparkles(sw, mapH),
                  ],
                ),
              ),
            ),

            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_LG.gLight, _LG.gMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _LG.gMid.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(top: -18, right: -18,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(bottom: -12, left: 40,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Row content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _LG.inkDark, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 2),
                const Text('🗺️', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chapterTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _LG.inkDark,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Lesson Map  🌿',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _LG.inkMid,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress pill
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏅', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '1/${_topics.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _LG.inkDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Overview node ─────────────────────────────────────────────────────────
  Widget _buildOverviewNode(double sw, double mapH) {
    final double left = 16.0;
    final double top  = mapH * 0.06;

    final anim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    return Positioned(
      left: left,
      top:  top,
      child: AnimatedBuilder(
        animation: Listenable.merge([anim, _pulseScale]),
        builder: (_, child) => Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: anim.value.clamp(0.0, 1.0) * _pulseScale.value,
            child: child,
          ),
        ),
        child: GestureDetector(
          onTap: () => _openSheet(context, 'Overview',
              emoji: '🌿', c1: _LG.gLight, c2: _LG.gMid),
          child: Container(
            width: 130, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_LG.gPale, _LG.gLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _LG.gMid, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _LG.gMid.withOpacity(0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🗺️', style: TextStyle(fontSize: 16)),
                SizedBox(width: 6),
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _LG.inkDark,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Topic node ────────────────────────────────────────────────────────────
  Widget _buildTopicNode(
      _LTopicData data, int index, double sw, double mapH) {
    final double startT = (index * 0.15).clamp(0.0, 0.55);
    final double endT   = (startT + 0.50).clamp(0.0, 1.0);

    final anim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Interval(startT, endT, curve: Curves.easeOutBack),
    );

    final floatPhase = index * 0.25;

    return Positioned(
      left: data.dx * sw - 38,
      top:  data.dy * mapH - 38,
      child: AnimatedBuilder(
        animation: Listenable.merge([anim, _floatCtrl]),
        builder: (_, child) {
          final opacity = anim.value.clamp(0.0, 1.0);
          final scale   = anim.value.clamp(0.0, 1.2);
          final floatDy = math.sin(
              (_floatCtrl.value + floatPhase) * 2 * math.pi) * 5.0;
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, floatDy),
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
        child: _LTopicNodeWidget(
          data: data,
          pulseCtrl: _pulseCtrl,
          onTap: () => data.locked
              ? _lockedSheet(context)
              : _openSheet(context, data.label,
                    emoji: data.emoji, c1: data.c1, c2: data.c2),
        ),
      ),
    );
  }

  // ── Orbit sparkles ────────────────────────────────────────────────────────
  List<Widget> _buildOrbitSparkles(double sw, double mapH) {
    final List<Widget> out = [];
    for (int i = 0; i < _topics.length; i++) {
      final t = _topics[i];
      if (!t.locked) continue;

      final cx = t.dx * sw;
      final cy = t.dy * mapH;
      const double radius = 52.0;

      out.add(AnimatedBuilder(
        animation: _orbitAngle,
        builder: (_, __) {
          final baseAngle = _orbitAngle.value + i * (math.pi * 2 / 3);
          return Stack(children: List.generate(3, (j) {
            final angle = baseAngle + j * (math.pi * 2 / 3);
            final ox = cx + radius * math.cos(angle) - 6;
            final oy = cy + radius * math.sin(angle) - 6;
            return Positioned(
              left: ox, top: oy,
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: t.c1,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: t.c1.withOpacity(0.7),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }));
        },
      ));
    }
    return out;
  }

  // ── Locked sheet ──────────────────────────────────────────────────────────
  void _lockedSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _LSheetWrapper(
        child: Row(
          children: [
            Container(
              width: 54, height: 54,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_LG.node2A, _LG.node2B],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded,
                  color: _LG.inkDark, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson Locked 🔒',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: _LG.inkDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Complete earlier lessons first!',
                    style: TextStyle(fontSize: 13, color: _LG.inkLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Open topic sheet ──────────────────────────────────────────────────────
  void _openSheet(
    BuildContext ctx,
    String label, {
    required String emoji,
    required Color  c1,
    required Color  c2,
  }) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LSheetWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 44, height: 5,
              decoration: BoxDecoration(
                color: _LG.inkLight.withOpacity(0.35),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 22),
            // Icon
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c1, c2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: c2.withOpacity(0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _LG.inkDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Ready to practise? Let's go! 🌿",
              style: TextStyle(color: _LG.inkLight, fontSize: 13),
            ),
            const SizedBox(height: 26),
            // Start learning button
            _LSheetStartButton(
              c1: c1, c2: c2,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LanguageTopicDetailPage(topicTitle: label),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Bottom nav (green active pill) ────────────────────────────────────────
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
            color: _LG.gMid.withOpacity(0.2),
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
              if (index == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchPage()));
              } else if (index == 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()));
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _LG.gLight : Colors.transparent,
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
                      color: isActive ? _LG.inkDark : _LG.inkLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isActive ? _LG.inkDark : _LG.inkLight,
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
// TOPIC NODE WIDGET  (green themed)
// =============================================================================
class _LTopicNodeWidget extends StatefulWidget {
  final _LTopicData data;
  final AnimationController pulseCtrl;
  final VoidCallback onTap;
  const _LTopicNodeWidget({
    required this.data,
    required this.pulseCtrl,
    required this.onTap,
  });

  @override
  State<_LTopicNodeWidget> createState() => _LTopicNodeWidgetState();
}

class _LTopicNodeWidgetState extends State<_LTopicNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _pressScale = Tween<double>(begin: 1.0, end: 0.86).animate(
        CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp:   (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock badge above
            if (d.locked)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 26, height: 26,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [d.c1, d.c2]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: d.c2.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: _LG.inkDark, size: 13),
                ),
              ),

            // Main circle
            AnimatedBuilder(
              animation: widget.pulseCtrl,
              builder: (_, child) {
                final extra = d.locked
                    ? 0.0
                    : (widget.pulseCtrl.value - 0.5).abs() * 0.06;
                return Transform.scale(scale: 1.0 + extra, child: child);
              },
              child: Container(
                width: 76, height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [d.c1, d.c2],
                    center: Alignment.topLeft,
                    radius: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: d.c2.withOpacity(0.45),
                      blurRadius: 18,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(d.emoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 2),
                    Text(
                      d.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _LG.inkDark,
                        height: 1.2,
                      ),
                    ),
                  ],
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
// PATH PAINTER  (green gradient paths)
// =============================================================================
class _LPathPainter extends CustomPainter {
  final List<_LTopicData> topics;
  final List<List<int>>   connections;
  final double mapW, mapH;
  final double progress;
  final double shimmerT;

  const _LPathPainter({
    required this.topics,
    required this.connections,
    required this.mapW,
    required this.mapH,
    required this.progress,
    required this.shimmerT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int ci = 0; ci < connections.length; ci++) {
      final a = topics[connections[ci][0]];
      final b = topics[connections[ci][1]];

      final double ax = a.dx * mapW;
      final double ay = a.dy * mapH;
      final double bx = b.dx * mapW;
      final double by = b.dy * mapH;

      final double cpx = (ax + bx) / 2 + (ay - by) * 0.22;
      final double cpy = (ay + by) / 2 + (bx - ax) * 0.14;

      // Dashed background track — soft green
      final dashPaint = Paint()
        ..color = _LG.gMid.withOpacity(0.18)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final fullPath = Path()
        ..moveTo(ax, ay)
        ..quadraticBezierTo(cpx, cpy, bx, by);
      _drawDashedPath(canvas, fullPath, dashPaint);

      // Animated draw-in path
      if (progress > 0) {
        final drawPath =
            _extractPartialPath(ax, ay, cpx, cpy, bx, by, progress);

        final linePaint = Paint()
          ..shader = LinearGradient(
            colors: [a.c1.withOpacity(0.85), b.c1.withOpacity(0.85)],
          ).createShader(
              Rect.fromPoints(Offset(ax, ay), Offset(bx, by)))
          ..strokeWidth = 4.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(drawPath, linePaint);

        // Travelling shimmer bead
        if (progress >= 1.0) {
          final bead = _bezierPoint(ax, ay, cpx, cpy, bx, by, shimmerT);
          canvas.drawCircle(
            bead, 7,
            Paint()
              ..color = Colors.white.withOpacity(0.9)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
          canvas.drawCircle(
              bead, 4.5, Paint()..color = _LG.gMid.withOpacity(0.9));
        }
      }

      // Glowing end dots
      _drawGlowDot(canvas, Offset(ax, ay), a.c1);
      _drawGlowDot(canvas, Offset(bx, by), b.c1);
    }
  }

  Offset _bezierPoint(double ax, double ay, double cpx, double cpy,
      double bx, double by, double t) {
    final mt = 1 - t;
    return Offset(
      mt * mt * ax + 2 * mt * t * cpx + t * t * bx,
      mt * mt * ay + 2 * mt * t * cpy + t * t * by,
    );
  }

  Path _extractPartialPath(double ax, double ay, double cpx, double cpy,
      double bx, double by, double t) {
    final path = Path();
    path.moveTo(ax, ay);
    const int steps = 40;
    final int count = (steps * t).round().clamp(1, steps);
    for (int s = 1; s <= count; s++) {
      final pt = _bezierPoint(ax, ay, cpx, cpy, bx, by, s / steps);
      path.lineTo(pt.dx, pt.dy);
    }
    return path;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      const double dash = 8, gap = 6;
      while (dist < metric.length) {
        final end = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dash + gap;
      }
    }
  }

  void _drawGlowDot(Canvas canvas, Offset centre, Color color) {
    canvas.drawCircle(
      centre, 7,
      Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(centre, 5, Paint()..color = color.withOpacity(0.85));
    canvas.drawCircle(
        centre, 3, Paint()..color = Colors.white.withOpacity(0.9));
  }

  @override
  bool shouldRepaint(_LPathPainter old) =>
      old.progress != progress || old.shimmerT != shimmerT;
}

// =============================================================================
// ANIMATED BACKGROUND  (green variant)
// =============================================================================
class _LAnimatedBg extends StatelessWidget {
  final AnimationController floatCtrl;
  const _LAnimatedBg({required this.floatCtrl});

  static const List<_LFloatItem> _floaties = [
    _LFloatItem('🌿', 0.88, 0.18, 0.0),
    _LFloatItem('✨', 0.05, 0.28, 0.3),
    _LFloatItem('🍃', 0.74, 0.48, 0.6),
    _LFloatItem('💬', 0.46, 0.66, 0.9),
    _LFloatItem('🌱', 0.18, 0.76, 0.2),
    _LFloatItem('📖', 0.83, 0.70, 0.5),
    _LFloatItem('✍️', 0.55, 0.84, 0.8),
    _LFloatItem('🗣️', 0.30, 0.10, 0.1),
    _LFloatItem('🌸', 0.91, 0.44, 0.7),
    _LFloatItem('⭐', 0.40, 0.88, 0.4),
  ];

  static const _bgIcons = <_LBgIcon>[
    _LBgIcon(Icons.translate_rounded,       0.03, 0.05, 28,  10),
    _LBgIcon(Icons.record_voice_over_rounded,0.62, 0.01, 34,  -6),
    _LBgIcon(Icons.spellcheck_rounded,      0.83, 0.12, 30,   4),
    _LBgIcon(Icons.chat_bubble_outline,     0.87, 0.40, 26, -14),
    _LBgIcon(Icons.menu_book_outlined,      0.70, 0.62, 28,  18),
    _LBgIcon(Icons.headphones_rounded,      0.48, 0.76, 32,  -4),
    _LBgIcon(Icons.edit_note_rounded,       0.14, 0.82, 26,  20),
    _LBgIcon(Icons.stars_rounded,           0.54, 0.20, 22,  22),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, bc) {
      final w = bc.maxWidth, h = bc.maxHeight;
      return Stack(children: [
        // Green gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFEEF8F3),
                Color(0xFFF2FAF6),
                Color(0xFFEAF6F0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Corner blobs — all green
        Positioned(top: -40, right: -40,
          child: Container(
            width: 150, height: 150,
            decoration: BoxDecoration(
              color: _LG.gLight.withOpacity(0.28),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(bottom: -50, left: -30,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              color: _LG.gMid.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(top: h * 0.35, right: -30,
          child: Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              color: _LG.node2A.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Static icon watermarks
        ..._bgIcons.map((d) => Positioned(
          left: d.dx * w, top: d.dy * h,
          child: Transform.rotate(
            angle: d.angle * math.pi / 180,
            child: Icon(d.icon, size: d.size,
                color: _LG.gDark.withOpacity(0.07)),
          ),
        )),

        // Animated floating emoji particles
        ..._floaties.map((f) => AnimatedBuilder(
          animation: floatCtrl,
          builder: (_, __) {
            final t  = (floatCtrl.value + f.phase) % 1.0;
            final dy = math.sin(t * 2 * math.pi) * 8.0;
            return Positioned(
              left: f.dx * w,
              top:  f.dy * h + dy,
              child: Opacity(
                opacity: 0.32,
                child: Text(f.emoji,
                    style: const TextStyle(fontSize: 18)),
              ),
            );
          },
        )),
      ]);
    });
  }
}

// =============================================================================
// SHEET WRAPPER  (green shadow)
// =============================================================================
class _LSheetWrapper extends StatelessWidget {
  final Widget child;
  const _LSheetWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Transform.translate(
        offset: Offset(0, (1 - v) * 80),
        child: Opacity(opacity: v, child: child),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 24),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _LG.gMid.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// =============================================================================
// SHEET START BUTTON  (green gradient)
// =============================================================================
class _LSheetStartButton extends StatefulWidget {
  final Color c1, c2;
  final VoidCallback onTap;
  const _LSheetStartButton({
    required this.c1, required this.c2, required this.onTap});

  @override
  State<_LSheetStartButton> createState() => _LSheetStartButtonState();
}

class _LSheetStartButtonState extends State<_LSheetStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _onTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.c1, widget.c2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.c2.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌿', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Start Practising',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _LG.inkDark,
                  letterSpacing: 0.3,
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
// HELPER DATA CLASSES
// =============================================================================
class _LBgIcon {
  final IconData icon;
  final double dx, dy, size, angle;
  const _LBgIcon(this.icon, this.dx, this.dy, this.size, this.angle);
}