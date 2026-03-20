import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'topic_detail_page.dart';
import 'search_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'services/session_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PASTEL PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class _P {
  static const bg       = Color(0xFFF7F4FB);
  static const inkDark  = Color(0xFF3D3660);
  static const inkMid   = Color(0xFF6B6490);
  static const inkLight = Color(0xFF9E9BBF);
  static const lavDark  = Color(0xFFB8A6D9);
  static const lavMid   = Color(0xFFC9B8E8);
  static const lavLight = Color(0xFFEAE3F7);
  static const mintA    = Color(0xFFB8E4D8);
  static const mintB    = Color(0xFF9DD4C5);
  static const blushA   = Color(0xFFF2C4CE);
  static const blushB   = Color(0xFFE8A8B5);
  static const peachA   = Color(0xFFF9D9B8);
  static const peachB   = Color(0xFFF0C49A);
  static const skyA     = Color(0xFFB8D8F2);
  static const skyB     = Color(0xFF9DC8EA);
  static const lemonA   = Color(0xFFF2EDB8);
  static const lemonB   = Color(0xFFE8E09A);
  static const lilacA   = Color(0xFFD8B8F2);
  static const lilacB   = Color(0xFFC8A0E8);
  static const sagA     = Color(0xFFC8DFC4);
  static const sagB     = Color(0xFFB0CCA8);
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA TYPES
// ─────────────────────────────────────────────────────────────────────────────
class _TopicData {
  final String label;
  final String emoji;
  final bool   locked;
  final double dx, dy;
  final Color  c1, c2;
  const _TopicData({
    required this.label, required this.emoji,
    required this.locked, required this.dx, required this.dy,
    required this.c1, required this.c2,
  });
}

class _FloatItem {
  final String emoji;
  final double dx, dy, phase;
  const _FloatItem(this.emoji, this.dx, this.dy, this.phase);
}

// ─────────────────────────────────────────────────────────────────────────────
// TOPIC MAP PAGE
// ─────────────────────────────────────────────────────────────────────────────
class TopicMapPage extends StatefulWidget {
  final String       chapterTitle;
  final List<String> topics;
  final String?      chapterId;
  final String?      subjectName;   // ← needed for collision-proof key
  final String?      board;
  final String?      className;

  const TopicMapPage({
    super.key,
    required this.chapterTitle,
    this.topics      = const [],
    this.chapterId,
    this.subjectName,
    this.board,
    this.className,
  });

  @override
  State<TopicMapPage> createState() => _TopicMapPageState();
}

class _TopicMapPageState extends State<TopicMapPage>
    with TickerProviderStateMixin {
  int _bottomNavIndex = 0;

  late final List<_TopicData> _topics;
  late final List<List<int>>  _connections;

  // Resolved session fields
  late final String _board;
  late final String _className;
  late final String _subjectName;
  late final String _chapterId;

  // Completed set — loaded from Hive on init, updated after video watched
  late Set<int> _completedTopics;

  static const _palette = [
    [_P.mintA,  _P.mintB ],
    [_P.blushA, _P.blushB],
    [_P.lemonA, _P.lemonB],
    [_P.lilacA, _P.lilacB],
    [_P.skyA,   _P.skyB  ],
    [_P.peachA, _P.peachB],
    [_P.sagA,   _P.sagB  ],
  ];

  static const _emojis = ['🌱','🔥','⚡','🌟','🎯','💡','🧪','📐','🌍','📖'];

  static const _positions = [
    [0.14, 0.80], [0.38, 0.62], [0.62, 0.44],
    [0.80, 0.26], [0.55, 0.14], [0.28, 0.20],
    [0.18, 0.38], [0.45, 0.30], [0.70, 0.52],
    [0.85, 0.70],
  ];

  // Animation controllers (all unchanged)
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

  static const List<_FloatItem> _floaties = [
    _FloatItem('⭐', 0.85, 0.08, 0.0),
    _FloatItem('✏️', 0.06, 0.22, 0.3),
    _FloatItem('📐', 0.76, 0.42, 0.6),
    _FloatItem('🔭', 0.44, 0.60, 0.9),
    _FloatItem('📚', 0.20, 0.70, 0.2),
    _FloatItem('🧪', 0.80, 0.68, 0.5),
    _FloatItem('🎯', 0.52, 0.82, 0.8),
    _FloatItem('💡', 0.28, 0.15, 0.1),
    _FloatItem('🖊️', 0.90, 0.30, 0.7),
    _FloatItem('🧮', 0.38, 0.88, 0.4),
  ];

  @override
  void initState() {
    super.initState();

    // Resolve session
    final session = SessionService.instance.getSession();
    _board       = widget.board       ?? session?.board       ?? 'CBSE';
    _className   = widget.className   ?? session?.className   ?? 'Class 10';
    _subjectName = widget.subjectName ?? 'Unknown';
    _chapterId   = widget.chapterId   ?? widget.chapterTitle;

    // Load which topics are already completed
    _completedTopics = _loadCompleted();

    // Build topic list
    final rawTopics = widget.topics.isNotEmpty
        ? widget.topics
        : ['Topic 1', 'Topic 2', 'Topic 3', 'Topic 4'];

    _topics = List.generate(rawTopics.length.clamp(1, 10), (i) {
      final colors = _palette[i % _palette.length];
      final emoji  = _emojis[i % _emojis.length];
      final pos    = _positions[i % _positions.length];
      // Locked if previous topic not completed
      final locked = i > 0 && !_completedTopics.contains(i - 1);
      return _TopicData(
        label: rawTopics[i], emoji: emoji, locked: locked,
        dx: pos[0], dy: pos[1],
        c1: colors[0] as Color, c2: colors[1] as Color,
      );
    });

    _connections = List.generate(
      (_topics.length - 1).clamp(0, 9), (i) => [i, i + 1]);

    // Animations (unchanged)
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    _pathCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pathProgress = CurvedAnimation(parent: _pathCtrl, curve: Curves.easeInOut);

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.94, end: 1.06)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _orbitAngle = Tween<double>(begin: 0, end: 2 * math.pi).animate(_orbitCtrl);

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

  // ── Load completed topics using collision-proof key ────────────────────────
  Set<int> _loadCompleted() {
    final session  = SessionService.instance.getSession();
    final board    = widget.board       ?? session?.board       ?? 'CBSE';
    final cls      = widget.className   ?? session?.className   ?? 'Class 10';
    final subject  = widget.subjectName ?? 'Unknown';
    final chapId   = widget.chapterId   ?? widget.chapterTitle;

    final rawTopics = widget.topics.isNotEmpty ? widget.topics
        : ['Topic 1', 'Topic 2', 'Topic 3', 'Topic 4'];

    final done = <int>{};
    for (int i = 0; i < rawTopics.length; i++) {
      if (SessionService.instance.isTopicComplete(
        board: board, className: cls,
        subjectName: subject, chapterId: chapId,
        topicIndex: i,
      )) done.add(i);
    }
    return done;
  }

  // ── Called from TopicDetailPage when 2-min watch threshold is met ──────────
  void _onTopicWatched(int index) {
    SessionService.instance.markTopicComplete(
      board: _board, className: _className,
      subjectName: _subjectName, chapterId: _chapterId,
      topicIndex: index,
    );
    if (mounted) setState(() => _completedTopics.add(index));
  }

  int get _doneCount => _completedTopics.length;

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

  @override
  Widget build(BuildContext context) {
    final mq         = MediaQuery.of(context);
    final double sw  = mq.size.width;
    final double sh  = mq.size.height;
    const double navH    = 68.0;
    const double appBarH = 72.0;
    final double mapH    = sh - mq.padding.top - appBarH - navH;

    return Scaffold(
      backgroundColor: _P.bg,
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(position: _headerSlide,
                  child: _buildAppBar()),
            ),
            Expanded(
              child: SizedBox(
                width: sw, height: mapH,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(child: _AnimatedBg(floatCtrl: _floatCtrl)),
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_pathProgress, _shimmerCtrl]),
                        builder: (_, __) => CustomPaint(
                          painter: _PathPainter(
                            topics: _topics, connections: _connections,
                            mapW: sw, mapH: mapH,
                            progress: _pathProgress.value,
                            shimmerT: _shimmerCtrl.value,
                          ),
                        ),
                      ),
                    ),
                    _buildOverviewNode(sw, mapH),
                    ..._topics.asMap().entries.map((e) =>
                        _buildTopicNode(e.value, e.key, sw, mapH)),
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

  Widget _buildAppBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_P.lavMid, _P.lavDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
        boxShadow: [BoxShadow(color: _P.lavDark.withOpacity(0.4),
            blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Stack(children: [
        Positioned(top: -18, right: -18,
          child: Container(width: 90, height: 90,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle))),
        Positioned(bottom: -12, left: 40,
          child: Container(width: 60, height: 60,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _P.inkDark, size: 20),
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
                  Text(widget.chapterTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                      color: _P.inkDark, letterSpacing: 0.2),
                    overflow: TextOverflow.ellipsis),
                  const Text('Topic Map  ✨',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: _P.inkMid)),
                ],
              ),
            ),
            // Progress pill
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('🏆', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text('$_doneCount/${_topics.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                    color: _P.inkDark)),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildOverviewNode(double sw, double mapH) {
    final anim = CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut));
    return Positioned(
      left: 16.0, top: mapH * 0.06,
      child: AnimatedBuilder(
        animation: Listenable.merge([anim, _pulseScale]),
        builder: (_, child) => Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: anim.value.clamp(0.0, 1.0) * _pulseScale.value,
            child: child),
        ),
        child: GestureDetector(
          onTap: () => _openSheet(context, 'Overview',
              emoji: '🗺️', c1: _P.lavMid, c2: _P.lavDark, topicIndex: -1),
          child: Container(
            width: 130, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_P.lavLight, _P.lavMid],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _P.lavDark, width: 2),
              boxShadow: [BoxShadow(color: _P.lavDark.withOpacity(0.35),
                blurRadius: 14, spreadRadius: 1, offset: const Offset(0, 5))],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🗺️', style: TextStyle(fontSize: 16)),
                SizedBox(width: 6),
                Text('Overview', style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w900, color: _P.inkDark,
                  letterSpacing: 0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicNode(_TopicData data, int index, double sw, double mapH) {
    final double startT = (index * 0.15).clamp(0.0, 0.55);
    final double endT   = (startT + 0.50).clamp(0.0, 1.0);
    final anim = CurvedAnimation(parent: _entranceCtrl,
        curve: Interval(startT, endT, curve: Curves.elasticOut));
    final floatPhase = index * 0.25;
    final isDone = _completedTopics.contains(index);

    return Positioned(
      left: data.dx * sw - 38, top: data.dy * mapH - 38,
      child: AnimatedBuilder(
        animation: Listenable.merge([anim, _floatCtrl]),
        builder: (_, child) {
          final opacity = anim.value.clamp(0.0, 1.0);
          final scale   = anim.value.clamp(0.0, 1.2);
          final floatDy = math.sin((_floatCtrl.value + floatPhase) * 2 * math.pi) * 5.0;
          return Opacity(opacity: opacity,
            child: Transform.translate(offset: Offset(0, floatDy),
              child: Transform.scale(scale: scale, child: child)));
        },
        child: _TopicNodeWidget(
          data: data,
          isDone: isDone,
          pulseCtrl: _pulseCtrl,
          onTap: () => data.locked
              ? _lockedSheet(context)
              : _openSheet(context, data.label,
                  emoji: data.emoji, c1: data.c1, c2: data.c2,
                  topicIndex: index),
        ),
      ),
    );
  }

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
            return Positioned(left: ox, top: oy,
              child: Opacity(opacity: 0.6,
                child: Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: t.c1, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: t.c1.withOpacity(0.7),
                        blurRadius: 6, spreadRadius: 1)]))));
          }));
        },
      ));
    }
    return out;
  }

  void _lockedSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent,
      builder: (_) => _SheetWrapper(
        child: Row(children: [
          Container(width: 54, height: 54,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_P.blushA, _P.blushB]),
              shape: BoxShape.circle),
            child: const Icon(Icons.lock_rounded, color: _P.inkDark, size: 24)),
          const SizedBox(width: 16),
          const Expanded(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Topic Locked 🔒',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                  color: _P.inkDark)),
              SizedBox(height: 4),
              Text('Watch the previous topic video first!',
                style: TextStyle(fontSize: 13, color: _P.inkLight)),
            ],
          )),
        ]),
      ),
    );
  }

  void _openSheet(BuildContext ctx, String label, {
    required String emoji, required Color c1, required Color c2,
    required int topicIndex,
  }) {
    final isDone = topicIndex >= 0 && _completedTopics.contains(topicIndex);

    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SheetWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 5,
              decoration: BoxDecoration(color: _P.inkLight.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 22),
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c1, c2],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: c2.withOpacity(0.45),
                    blurRadius: 18, spreadRadius: 2)]),
              child: Center(child: Text(emoji,
                  style: const TextStyle(fontSize: 30)))),
            const SizedBox(height: 14),
            Text(label, style: const TextStyle(fontSize: 22,
                fontWeight: FontWeight.w900, color: _P.inkDark)),
            const SizedBox(height: 6),
            Text(
              isDone ? '✅ Completed!' : "Watch the video to complete this topic 🎬",
              style: const TextStyle(color: _P.inkLight, fontSize: 13)),
            const SizedBox(height: 26),
            // Only show Start button if not overview
            if (topicIndex >= 0)
              _SheetStartButton(
                c1: c1, c2: c2,
                label: isDone ? 'Watch Again 🔁' : 'Start Learning 🎓',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TopicDetailPage(
                        topicTitle:   label,
                        chapterId:    _chapterId,
                        subjectName:  _subjectName,
                        topicIndex:   topicIndex,
                        totalTopics:  _topics.length,
                        board:        _board,
                        className:    _className,
                        onWatched: () => _onTopicWatched(topicIndex), // ← callback
                      ),
                    ),
                  ).then((_) => setState(() {})); // refresh lock states
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,        'label': 'Home'},
      {'icon': Icons.search_rounded,      'label': 'Search'},
      {'icon': Icons.access_time_rounded, 'label': 'History'},
      {'icon': Icons.person_rounded,      'label': 'Profile'},
      {'icon': Icons.settings_rounded,    'label': 'Settings'},
    ];
    return Container(
      decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: _P.lavMid.withOpacity(0.2),
            blurRadius: 16, offset: const Offset(0, -4))]),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = _bottomNavIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
              else if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
              else if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              else setState(() => _bottomNavIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _P.lavLight : Colors.transparent,
                borderRadius: BorderRadius.circular(14)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedScale(scale: isActive ? 1.22 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Icon(items[index]['icon'] as IconData, size: 24,
                    color: isActive ? _P.inkDark : _P.inkLight)),
                const SizedBox(height: 3),
                Text(items[index]['label'] as String,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: isActive ? _P.inkDark : _P.inkLight)),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// TOPIC NODE WIDGET
// =============================================================================
class _TopicNodeWidget extends StatefulWidget {
  final _TopicData data;
  final bool isDone;
  final AnimationController pulseCtrl;
  final VoidCallback onTap;
  const _TopicNodeWidget({
    required this.data, required this.isDone,
    required this.pulseCtrl, required this.onTap});
  @override State<_TopicNodeWidget> createState() => _TopicNodeWidgetState();
}

class _TopicNodeWidgetState extends State<_TopicNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double>   _pressScale;

  @override void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120));
    _pressScale = Tween<double>(begin: 1.0, end: 0.86)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn));
  }
  @override void dispose() { _pressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown:   (_) => _pressCtrl.forward(),
      onTapUp:     (_) => _pressCtrl.reverse(),
      onTapCancel: ()  => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (d.locked)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 26, height: 26,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [d.c1, d.c2]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: d.c2.withOpacity(0.5),
                      blurRadius: 8, offset: const Offset(0, 2))]),
                child: const Icon(Icons.lock_rounded, color: _P.inkDark, size: 13)),
            ),
          AnimatedBuilder(
            animation: widget.pulseCtrl,
            builder: (_, child) {
              final extra = d.locked ? 0.0
                  : (widget.pulseCtrl.value - 0.5).abs() * 0.06;
              return Transform.scale(scale: 1.0 + extra, child: child);
            },
            child: Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Purple ring when completed
                border: widget.isDone
                    ? Border.all(color: const Color(0xFF5B1F7A), width: 3)
                    : null,
                gradient: RadialGradient(colors: [d.c1, d.c2],
                  center: Alignment.topLeft, radius: 1.8),
                boxShadow: [
                  BoxShadow(color: d.c2.withOpacity(0.45),
                      blurRadius: 18, spreadRadius: 2, offset: const Offset(0, 6)),
                  BoxShadow(color: Colors.white.withOpacity(0.5),
                      blurRadius: 4, offset: const Offset(-2, -2)),
                ],
              ),
              child: Stack(alignment: Alignment.center, children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(d.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 2),
                  Text(d.label, textAlign: TextAlign.center,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
                      color: _P.inkDark, height: 1.2)),
                ]),
                // ✓ tick when done
                if (widget.isDone)
                  Positioned(top: 4, right: 4,
                    child: Container(width: 18, height: 18,
                      decoration: const BoxDecoration(color: Color(0xFF5B1F7A),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 11))),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// =============================================================================
// PATH PAINTER  (unchanged)
// =============================================================================
class _PathPainter extends CustomPainter {
  final List<_TopicData> topics;
  final List<List<int>>  connections;
  final double mapW, mapH, progress, shimmerT;
  const _PathPainter({required this.topics, required this.connections,
    required this.mapW, required this.mapH,
    required this.progress, required this.shimmerT});

  @override
  void paint(Canvas canvas, Size size) {
    for (int ci = 0; ci < connections.length; ci++) {
      final a = topics[connections[ci][0]];
      final b = topics[connections[ci][1]];
      final ax = a.dx * mapW; final ay = a.dy * mapH;
      final bx = b.dx * mapW; final by = b.dy * mapH;
      final cpx = (ax + bx) / 2 + (ay - by) * 0.22;
      final cpy = (ay + by) / 2 + (bx - ax) * 0.14;

      _drawDashedPath(canvas,
        Path()..moveTo(ax, ay)..quadraticBezierTo(cpx, cpy, bx, by),
        Paint()..color = a.c1.withOpacity(0.18)..strokeWidth = 5.0
          ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

      if (progress > 0) {
        canvas.drawPath(_extractPartialPath(ax,ay,cpx,cpy,bx,by,progress),
          Paint()
            ..shader = LinearGradient(colors:[a.c1.withOpacity(0.85),b.c1.withOpacity(0.85)])
              .createShader(Rect.fromPoints(Offset(ax,ay),Offset(bx,by)))
            ..strokeWidth = 4.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

        if (progress >= 1.0) {
          final bead = _bezierPoint(ax,ay,cpx,cpy,bx,by,shimmerT);
          canvas.drawCircle(bead, 7,
            Paint()..color=Colors.white.withOpacity(0.9)
              ..maskFilter=const MaskFilter.blur(BlurStyle.normal,4));
          canvas.drawCircle(bead, 4.5, Paint()..color=b.c1.withOpacity(0.9));
        }
      }
      _drawGlowDot(canvas, Offset(ax,ay), a.c1);
      _drawGlowDot(canvas, Offset(bx,by), b.c1);
    }
  }

  Offset _bezierPoint(double ax,double ay,double cpx,double cpy,
      double bx,double by,double t) {
    final mt = 1-t;
    return Offset(mt*mt*ax+2*mt*t*cpx+t*t*bx, mt*mt*ay+2*mt*t*cpy+t*t*by);
  }

  Path _extractPartialPath(double ax,double ay,double cpx,double cpy,
      double bx,double by,double t) {
    final path = Path()..moveTo(ax,ay);
    final count = (40*t).round().clamp(1,40);
    for (int s=1; s<=count; s++) {
      final pt = _bezierPoint(ax,ay,cpx,cpy,bx,by,s/40);
      path.lineTo(pt.dx,pt.dy);
    }
    return path;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d,(d+8).clamp(0,m.length)), paint);
        d += 14;
      }
    }
  }

  void _drawGlowDot(Canvas canvas, Offset c, Color color) {
    canvas.drawCircle(c, 7, Paint()..color=color.withOpacity(0.4)
        ..maskFilter=const MaskFilter.blur(BlurStyle.normal,5));
    canvas.drawCircle(c, 5, Paint()..color=color.withOpacity(0.85));
    canvas.drawCircle(c, 3, Paint()..color=Colors.white.withOpacity(0.9));
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.progress != progress || old.shimmerT != shimmerT;
}

// =============================================================================
// ANIMATED BACKGROUND  (unchanged)
// =============================================================================
class _BgIcon {
  final IconData icon;
  final double dx, dy, size, angle;
  const _BgIcon(this.icon, this.dx, this.dy, this.size, this.angle);
}

class _AnimatedBg extends StatelessWidget {
  final AnimationController floatCtrl;
  const _AnimatedBg({required this.floatCtrl});

  static const _floaties = [
    _FloatItem('⭐',0.88,0.28,0.0), _FloatItem('✏️',0.05,0.34,0.3),
    _FloatItem('📐',0.74,0.54,0.6), _FloatItem('🔭',0.46,0.72,0.9),
    _FloatItem('📚',0.18,0.83,0.2), _FloatItem('🧪',0.83,0.76,0.5),
    _FloatItem('🎯',0.55,0.87,0.8), _FloatItem('💡',0.30,0.12,0.1),
    _FloatItem('🖊️',0.91,0.50,0.7), _FloatItem('🧮',0.40,0.91,0.4),
  ];
  static const _bgIcons = [
    _BgIcon(Icons.edit_rounded,0.03,0.05,28,10),
    _BgIcon(Icons.straighten_rounded,0.62,0.01,34,-6),
    _BgIcon(Icons.calculate_outlined,0.83,0.12,30,4),
    _BgIcon(Icons.science_outlined,0.87,0.40,26,-14),
    _BgIcon(Icons.architecture_rounded,0.70,0.62,28,18),
    _BgIcon(Icons.menu_book_outlined,0.48,0.76,32,-4),
    _BgIcon(Icons.brush_rounded,0.14,0.82,26,20),
    _BgIcon(Icons.push_pin_outlined,0.54,0.20,22,22),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, bc) {
      final w = bc.maxWidth, h = bc.maxHeight;
      return Stack(children: [
        Container(decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF2EEF8),Color(0xFFF7F4FB),Color(0xFFEEF3F8)],
            begin: Alignment.topLeft, end: Alignment.bottomRight))),
        Positioned(top:-40,right:-40, child: Container(width:150,height:150,
          decoration: BoxDecoration(color:_P.lavMid.withOpacity(0.20),shape:BoxShape.circle))),
        Positioned(bottom:-50,left:-30, child: Container(width:140,height:140,
          decoration: BoxDecoration(color:_P.mintA.withOpacity(0.22),shape:BoxShape.circle))),
        Positioned(top:h*0.35,right:-30, child: Container(width:110,height:110,
          decoration: BoxDecoration(color:_P.blushA.withOpacity(0.18),shape:BoxShape.circle))),
        ..._bgIcons.map((d) => Positioned(left:d.dx*w,top:d.dy*h,
          child: Transform.rotate(angle:d.angle*math.pi/180,
            child: Icon(d.icon,size:d.size,color:_P.lavDark.withOpacity(0.09))))),
        ..._floaties.map((f) => AnimatedBuilder(
          animation: floatCtrl,
          builder: (_,__) {
            final t  = (floatCtrl.value + f.phase) % 1.0;
            final dy = math.sin(t * 2 * math.pi) * 8.0;
            return Positioned(left:f.dx*w, top:f.dy*h+dy,
              child: Opacity(opacity:0.35,
                child: Text(f.emoji,style:const TextStyle(fontSize:18))));
          })),
      ]);
    });
  }
}

// =============================================================================
// SHEET WRAPPER  (unchanged)
// =============================================================================
class _SheetWrapper extends StatelessWidget {
  final Widget child;
  const _SheetWrapper({required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin:0,end:1),
      duration: const Duration(milliseconds:350),
      curve: Curves.easeOutCubic,
      builder: (_,v,child) => Transform.translate(
        offset: Offset(0,(1-v)*80), child: Opacity(opacity:v,child:child)),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14,0,14,24),
        padding: const EdgeInsets.fromLTRB(22,18,22,14),
        decoration: BoxDecoration(color:Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color:_P.lavDark.withOpacity(0.15),
              blurRadius:24,offset:const Offset(0,-4))]),
        child: child),
    );
  }
}

// =============================================================================
// SHEET START BUTTON
// =============================================================================
class _SheetStartButton extends StatefulWidget {
  final Color c1, c2;
  final String label;
  final VoidCallback onTap;
  const _SheetStartButton({required this.c1, required this.c2,
    required this.label, required this.onTap});
  @override State<_SheetStartButton> createState() => _SheetStartButtonState();
}
class _SheetStartButtonState extends State<_SheetStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync:this,duration:const Duration(milliseconds:120));
    _scale = Tween<double>(begin:1.0,end:0.93)
        .animate(CurvedAnimation(parent:_ctrl,curve:Curves.easeIn));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  Future<void> _onTap() async {
    await _ctrl.forward(); await _ctrl.reverse(); widget.onTap();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(scale: _scale,
        child: Container(
          width: double.infinity, height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors:[widget.c1,widget.c2],
              begin:Alignment.topLeft,end:Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color:widget.c2.withOpacity(0.45),
                blurRadius:14,offset:const Offset(0,5))]),
          child: Center(child: Text(widget.label,
            style: const TextStyle(fontSize:16, fontWeight:FontWeight.w900,
              color:_P.inkDark, letterSpacing:0.3))))),
    );
  }
}