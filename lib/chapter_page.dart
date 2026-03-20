import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'topic_map_page.dart';
import 'search_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'models/curriculum_model.dart';
import 'services/session_service.dart';
import 'data/curriculum_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared pastel palette
// ─────────────────────────────────────────────────────────────────────────────
class _C {
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
  static const powderA  = Color(0xFFC4D8F0);
  static const powderB  = Color(0xFFACC4E4);
  static const roseA    = Color(0xFFF5C6D0);
  static const roseB    = Color(0xFFEAADB8);
}

const _subjectMeta = <String, Map<String, dynamic>>{
  'Maths':          {'h1': _C.lavMid,  'h2': _C.lavDark, 'c1': _C.lavLight, 'c2': _C.lavMid,  'emoji': '🔢'},
  'Science':        {'h1': _C.mintA,   'h2': _C.mintB,   'c1': _C.mintA,    'c2': _C.mintB,   'emoji': '🧪'},
  'English':        {'h1': _C.blushA,  'h2': _C.blushB,  'c1': _C.blushA,   'c2': _C.blushB,  'emoji': '📖'},
  'History':        {'h1': _C.skyA,    'h2': _C.skyB,    'c1': _C.skyA,     'c2': _C.skyB,    'emoji': '🏛️'},
  'Geography':      {'h1': _C.peachA,  'h2': _C.peachB,  'c1': _C.peachA,   'c2': _C.peachB,  'emoji': '🌍'},
  'Physics':        {'h1': _C.lemonA,  'h2': _C.lemonB,  'c1': _C.lemonA,   'c2': _C.lemonB,  'emoji': '⚡'},
  'Chemistry':      {'h1': _C.lilacA,  'h2': _C.lilacB,  'c1': _C.lilacA,   'c2': _C.lilacB,  'emoji': '🧬'},
  'Biology':        {'h1': _C.sagA,    'h2': _C.sagB,    'c1': _C.sagA,     'c2': _C.sagB,    'emoji': '🌿'},
  'Computer':       {'h1': _C.powderA, 'h2': _C.powderB, 'c1': _C.powderA,  'c2': _C.powderB, 'emoji': '💻'},
  'Maths I':        {'h1': _C.lavMid,  'h2': _C.lavDark, 'c1': _C.lavLight, 'c2': _C.lavMid,  'emoji': '🔢'},
  'Maths II':       {'h1': _C.skyA,    'h2': _C.skyB,    'c1': _C.skyA,     'c2': _C.skyB,    'emoji': '📐'},
  'Science I':      {'h1': _C.mintA,   'h2': _C.mintB,   'c1': _C.mintA,    'c2': _C.mintB,   'emoji': '🧪'},
  'Science II':     {'h1': _C.sagA,    'h2': _C.sagB,    'c1': _C.sagA,     'c2': _C.sagB,    'emoji': '🌿'},
  'Social Science': {'h1': _C.peachA,  'h2': _C.peachB,  'c1': _C.peachA,   'c2': _C.peachB,  'emoji': '🏛️'},
  'Hindi':          {'h1': _C.roseA,   'h2': _C.roseB,   'c1': _C.roseA,    'c2': _C.roseB,   'emoji': '🔤'},
  'EVS':            {'h1': _C.sagA,    'h2': _C.sagB,     'c1': _C.sagA,    'c2': _C.sagB,    'emoji': '🌍'},
};

// ─────────────────────────────────────────────────────────────────────────────
// CHAPTER PAGE
// ─────────────────────────────────────────────────────────────────────────────
class ChapterPage extends StatefulWidget {
  final String        subjectName;
  final List<Chapter>? chapters;
  final String?       board;
  final String?       className;

  const ChapterPage({
    super.key,
    required this.subjectName,
    this.chapters,
    this.board,
    this.className,
  });

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage>
    with TickerProviderStateMixin {
  int _bottomNavIndex = 0;

  late final List<Chapter> _chapters;
  late final String        _board;
  late final String        _className;

  late AnimationController _headerCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _listCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _pulseAnim;

  Map<String, dynamic> get _meta =>
      _subjectMeta[widget.subjectName] ?? _subjectMeta['Maths']!;

  // ── A chapter is "done" when ALL its topics are completed ─────────────────
  bool _isChapterDone(Chapter chapter) {
    if (chapter.topics.isEmpty) return false;
    for (int i = 0; i < chapter.topics.length; i++) {
      if (!SessionService.instance.isTopicComplete(
        board:       _board,
        className:   _className,
        subjectName: widget.subjectName,
        chapterId:   chapter.id,
        topicIndex:  i,
      )) return false;
    }
    return true;
  }

  int get _doneCount => _chapters.where(_isChapterDone).length;

  @override
  void initState() {
    super.initState();

    final session = SessionService.instance.getSession();
    _board     = widget.board     ?? session?.board     ?? 'CBSE';
    _className = widget.className ?? session?.className ?? 'Class 10';

    if (widget.chapters != null && widget.chapters!.isNotEmpty) {
      _chapters = widget.chapters!;
    } else {
      final subjects = CurriculumData.getSubjects(_board, _className);
      final match    = subjects.where((s) => s.name == widget.subjectName).toList();
      _chapters = match.isNotEmpty ? match.first.chapters : _fallbackChapters;
    }

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  List<Chapter> get _fallbackChapters => [
    Chapter(id: 'f1', title: 'Chapter 1: Introduction',
        description: 'Getting started.', topics: ['Basics', 'Overview']),
    Chapter(id: 'f2', title: 'Chapter 2: Core Concepts',
        description: 'Key ideas.', topics: ['Concepts', 'Examples']),
    Chapter(id: 'f3', title: 'Chapter 3: Practice',
        description: 'Exercises.', topics: ['Problems', 'Solutions']),
  ];

  @override
  void dispose() {
    _headerCtrl.dispose();
    _floatCtrl.dispose();
    _listCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color h1 = _meta['h1'] as Color;
    final Color h2 = _meta['h2'] as Color;

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: _buildHeader(h1, h2),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  _buildBgBlobs(h1, h2),
                  ..._buildParticles(),
                  // ── Refresh list when returning from TopicMapPage ──────────
                  ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                    itemCount: _chapters.length,
                    itemBuilder: (ctx, i) {
                      final start = i * 0.15;
                      final end   = (start + 0.55).clamp(0.0, 1.0);
                      final anim  = CurvedAnimation(
                        parent: _listCtrl,
                        curve: Interval(start, end, curve: Curves.easeOutCubic),
                      );
                      return AnimatedBuilder(
                        animation: anim,
                        builder: (_, child) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.35), end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _ChapterCard(
                          chapter:      _chapters[i],
                          index:        i,
                          colorA:       _meta['c1'] as Color,
                          colorB:       _meta['c2'] as Color,
                          headerA:      h1,
                          headerB:      h2,
                          pulseAnim:    _pulseAnim,
                          subjectEmoji: _meta['emoji'] as String,
                          subjectName:  widget.subjectName,
                          board:        _board,
                          className:    _className,
                          isCompleted:  _isChapterDone(_chapters[i]),
                          // Called when TopicMapPage pops — refresh completion state
                          onReturn: () => setState(() {}),
                        ),
                      );
                    },
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

  Widget _buildHeader(Color h1, Color h2) {
    final done     = _doneCount;
    final progress = _chapters.isEmpty ? 0.0 : done / _chapters.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [h1, h2],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
        boxShadow: [BoxShadow(color: h2.withOpacity(0.45),
            blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Stack(children: [
        Positioned(top: -18, right: -18,
          child: Container(width: 110, height: 110,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle))),
        Positioned(bottom: -14, left: 24,
          child: Container(width: 70, height: 70,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.09),
                shape: BoxShape.circle))),
        Positioned(top: 10, right: 80,
          child: Container(width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle))),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 16, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: _C.inkDark, size: 20),
                onPressed: () => Navigator.maybePop(context)),
              const SizedBox(width: 4),
              Text(_meta['emoji'] as String,
                  style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.subjectName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                      color: _C.inkDark, letterSpacing: 0.2)),
                  Text('$_board · $_className',
                    style: const TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w600, color: _C.inkMid)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.menu_book_rounded, size: 14, color: _C.inkDark),
                  const SizedBox(width: 4),
                  Text('${_chapters.length}',
                    style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w800, color: _C.inkDark)),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('$done / ${_chapters.length} completed',
                    style: const TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w600, color: _C.inkMid)),
                  Text('${(progress * 100).round()}%',
                    style: const TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w800, color: _C.inkDark)),
                ]),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.35),
                    valueColor: const AlwaysStoppedAnimation<Color>(_C.inkDark),
                    minHeight: 6)),
              ]),
            ),
            const SizedBox(height: 4),
          ]),
        ),
      ]),
    );
  }

  Widget _buildBgBlobs(Color h1, Color h2) {
    return IgnorePointer(child: Stack(children: [
      Positioned(top: 20, right: -50,
        child: Container(width: 160, height: 160,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: h1.withOpacity(0.25)))),
      Positioned(top: 260, left: -55,
        child: Container(width: 140, height: 140,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: _C.mintA.withOpacity(0.3)))),
      Positioned(bottom: 60, right: -35,
        child: Container(width: 130, height: 130,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: _C.blushA.withOpacity(0.25)))),
    ]));
  }

  List<Widget> _buildParticles() {
    final items = [
      {'e': '✨', 'lf': 0.07, 'tf': 0.05, 'ph': 0.0},
      {'e': '📝', 'lf': 0.82, 'tf': 0.10, 'ph': 0.6},
      {'e': '🌟', 'lf': 0.88, 'tf': 0.35, 'ph': 1.1},
      {'e': '💫', 'lf': 0.04, 'tf': 0.52, 'ph': 0.4},
      {'e': '🎀', 'lf': 0.80, 'tf': 0.65, 'ph': 0.9},
    ];
    return items.map((item) => AnimatedBuilder(
      animation: _floatCtrl,
      builder: (ctx, _) {
        final sw = MediaQuery.of(ctx).size.width;
        final t  = (_floatCtrl.value + (item['ph'] as double)) % 1.0;
        final dy = math.sin(t * math.pi) * 9.0;
        return Positioned(
          left: sw  * (item['lf'] as double),
          top:  620 * (item['tf'] as double) + dy,
          child: IgnorePointer(child: Opacity(opacity: 0.4,
            child: Text(item['e'] as String,
                style: const TextStyle(fontSize: 17)))));
      })).toList();
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
        boxShadow: [BoxShadow(color: _C.lavMid.withOpacity(0.2),
            blurRadius: 16, offset: const Offset(0, -4))]),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = _bottomNavIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 1) Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchPage()));
              else if (index == 2) Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()));
              else if (index == 3) Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
              else setState(() => _bottomNavIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _C.lavLight : Colors.transparent,
                borderRadius: BorderRadius.circular(14)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedScale(scale: isActive ? 1.22 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Icon(items[index]['icon'] as IconData, size: 24,
                    color: isActive ? _C.inkDark : _C.inkLight)),
                const SizedBox(height: 3),
                Text(items[index]['label'] as String,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: isActive ? _C.inkDark : _C.inkLight)),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// CHAPTER CARD
// =============================================================================
class _ChapterCard extends StatefulWidget {
  final Chapter  chapter;
  final int      index;
  final Color    colorA, colorB;
  final Color    headerA, headerB;
  final Animation<double> pulseAnim;
  final String   subjectEmoji;
  final String   subjectName;   // ← needed for collision-proof topic key
  final String   board;
  final String   className;
  final bool     isCompleted;   // derived: all topics watched
  final VoidCallback onReturn;  // called on Navigator.pop to refresh parent

  const _ChapterCard({
    required this.chapter,
    required this.index,
    required this.colorA,
    required this.colorB,
    required this.headerA,
    required this.headerB,
    required this.pulseAnim,
    required this.subjectEmoji,
    required this.subjectName,
    required this.board,
    required this.className,
    required this.isCompleted,
    required this.onReturn,
  });

  @override
  State<_ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<_ChapterCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        margin: const EdgeInsets.only(bottom: 18),
        transform: Matrix4.identity()..translate(0.0, _pressed ? 2.0 : 0.0),
        decoration: BoxDecoration(
          color: widget.isCompleted ? const Color(0xFFEBE0FA) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: widget.isCompleted
              ? Border.all(color: const Color(0xFF9B6FBF), width: 1.5)
              : null,
          boxShadow: [BoxShadow(
            color: widget.colorB.withOpacity(_pressed ? 0.15 : 0.30),
            blurRadius: _pressed ? 6 : 16,
            offset: Offset(0, _pressed ? 2 : 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildThumbnail(),
          _buildFooter(context),
        ]),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22), topRight: Radius.circular(22)),
      child: Container(
        width: double.infinity, height: 155,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.headerA, widget.headerB, widget.colorA.withOpacity(0.7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Stack(children: [
          Positioned(right: -22, top: -22,
            child: Container(width: 110, height: 110,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.10),
                  shape: BoxShape.circle))),
          Positioned(left: -10, bottom: -12,
            child: Container(width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle))),
          Positioned(right: 50, bottom: -14,
            child: Container(width: 55, height: 55,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle))),

          // Chapter badge
          Positioned(top: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.7), width: 1)),
              child: Text('Ch. ${widget.index + 1}',
                style: const TextStyle(color: _C.inkDark, fontSize: 11,
                  fontWeight: FontWeight.w800)))),

          // Subject emoji
          Positioned(top: 12, right: 12,
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle),
              child: Center(child: Text(widget.subjectEmoji,
                  style: const TextStyle(fontSize: 18))))),

          // ✓ tick when all topics completed — NO manual toggle button
          if (widget.isCompleted)
            Positioned(top: 12, right: 56,
              child: Container(width: 30, height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B1F7A).withOpacity(0.85),
                  shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 16))),

          // Pulsing play button
          Center(child: AnimatedBuilder(
            animation: widget.pulseAnim,
            builder: (_, child) => Transform.scale(
                scale: widget.pulseAnim.value, child: child),
            child: Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.80),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: widget.headerB.withOpacity(0.4),
                    blurRadius: 16, spreadRadius: 2)]),
              child: const Icon(Icons.play_arrow_rounded,
                  color: _C.inkDark, size: 30)))),

          // Progress dots
          Positioned(bottom: 12, right: 14,
            child: Row(children: List.generate(3, (i) => Container(
              width: 6, height: 6,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: i == 0
                    ? Colors.white.withOpacity(0.9)
                    : Colors.white.withOpacity(0.35)))))),
        ]),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 15),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Accent bar
        Container(
          width: 4, height: 38,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.colorA, widget.colorB],
              begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(4))),

        // Title + description + topic chips
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chapter.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                color: _C.inkDark, height: 1.3)),
            const SizedBox(height: 3),
            Text(widget.chapter.description,
              style: const TextStyle(fontSize: 11, color: _C.inkLight,
                fontWeight: FontWeight.w500)),
            if (widget.chapter.topics.isNotEmpty) ...[
              const SizedBox(height: 5),
              Wrap(spacing: 4, runSpacing: 2,
                children: widget.chapter.topics.take(2).map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.colorA.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(t, style: const TextStyle(fontSize: 9,
                    fontWeight: FontWeight.w600, color: _C.inkDark)))).toList()),
            ],
          ],
        )),

        const SizedBox(width: 8),

        // Start button only — NO mark-complete toggle
        _StartButton(
          colorA: widget.colorA,
          colorB: widget.colorB,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopicMapPage(
                chapterTitle: widget.chapter.title,
                topics:       widget.chapter.topics,
                chapterId:    widget.chapter.id,
                subjectName:  widget.subjectName,   // ← collision-proof key
                board:        widget.board,
                className:    widget.className,
              ),
            ),
          ).then((_) => widget.onReturn()), // ← refresh completion badge
        ),
      ]),
    );
  }
}

// =============================================================================
// START BUTTON
// =============================================================================
class _StartButton extends StatefulWidget {
  final Color colorA, colorB;
  final VoidCallback onTap;
  const _StartButton({required this.colorA, required this.colorB,
    required this.onTap});
  @override State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 130));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _onTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.colorA, widget.colorB],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: widget.colorB.withOpacity(0.45),
                blurRadius: 10, offset: const Offset(0, 4))]),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Start', style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w800, color: _C.inkDark)),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios_rounded, size: 11, color: _C.inkDark),
          ]),
        )),
    );
  }
}