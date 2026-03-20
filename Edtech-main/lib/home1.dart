import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'chapter_page.dart';
import 'language_chapter_page.dart';
import 'search_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'services/session_service.dart';
import 'data/curriculum_data.dart';
import 'models/curriculum_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PASTEL PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
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
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBJECT META  (shared colour + emoji map — mirrors history_page.dart)
// ─────────────────────────────────────────────────────────────────────────────
const _kSubjectMeta = <String, Map<String, dynamic>>{
  'Maths':          {'c1': AppColors.lavMid,  'c2': AppColors.lavDark, 'e': '🔢'},
  'Science':        {'c1': AppColors.mintA,   'c2': AppColors.mintB,   'e': '🧪'},
  'English':        {'c1': AppColors.blushA,  'c2': AppColors.blushB,  'e': '📖'},
  'History':        {'c1': AppColors.skyA,    'c2': AppColors.skyB,    'e': '🏛️'},
  'Geography':      {'c1': AppColors.peachA,  'c2': AppColors.peachB,  'e': '🌍'},
  'Physics':        {'c1': AppColors.lemonA,  'c2': AppColors.lemonB,  'e': '⚡'},
  'Chemistry':      {'c1': AppColors.lilacA,  'c2': AppColors.lilacB,  'e': '🧬'},
  'Biology':        {'c1': AppColors.sagA,    'c2': AppColors.sagB,    'e': '🌿'},
  'Computer':       {'c1': AppColors.powderA, 'c2': AppColors.powderB, 'e': '💻'},
  'Maths I':        {'c1': AppColors.lavMid,  'c2': AppColors.lavDark, 'e': '🔢'},
  'Maths II':       {'c1': AppColors.skyA,    'c2': AppColors.skyB,    'e': '📐'},
  'Science I':      {'c1': AppColors.mintA,   'c2': AppColors.mintB,   'e': '🧪'},
  'Science II':     {'c1': AppColors.sagA,    'c2': AppColors.sagB,    'e': '🌿'},
  'Social Science': {'c1': AppColors.peachA,  'c2': AppColors.peachB,  'e': '🏛️'},
  'Hindi':          {'c1': AppColors.blushA,  'c2': AppColors.blushB,  'e': '🔤'},
  'EVS':            {'c1': AppColors.sagA,    'c2': AppColors.sagB,    'e': '🌍'},
};

Map<String, dynamic> _metaFor(String subject) =>
    _kSubjectMeta[subject] ??
    {'c1': AppColors.lavMid, 'c2': AppColors.lavDark, 'e': '📚'};

// ─────────────────────────────────────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────────────────────────────────────
class Home1Page extends StatefulWidget {
  const Home1Page({super.key});
  @override
  State<Home1Page> createState() => _Home1PageState();
}

class _Home1PageState extends State<Home1Page> with TickerProviderStateMixin {
  int _toggleIndex    = 0;
  int _bottomNavIndex = 0;

  late List<Subject>  _subjects;
  late UserSession    _session;

  static (Color, Color) _colorFor(String emoji) {
    const map = {
      '🔢': (AppColors.lavMid,  AppColors.lavDark),
      '🧪': (AppColors.mintA,   AppColors.mintB),
      '📖': (AppColors.blushA,  AppColors.blushB),
      '🏛️': (AppColors.skyA,    AppColors.skyB),
      '🌍': (AppColors.peachA,  AppColors.peachB),
      '⚡': (AppColors.lemonA,  AppColors.lemonB),
      '🧬': (AppColors.lilacA,  AppColors.lilacB),
      '🌿': (AppColors.sagA,    AppColors.sagB),
      '💻': (AppColors.powderA, AppColors.powderB),
      '📐': (AppColors.skyA,    AppColors.skyB),
      '🔤': (AppColors.peachA,  AppColors.peachB),
    };
    return map[emoji] ?? (AppColors.lavMid, AppColors.lavDark);
  }

  // Animation controllers
  late AnimationController _headerCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _owlCtrl;
  late AnimationController _streakCtrl;
  late AnimationController _bannerCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _owlBob;
  late Animation<double> _streakCount;
  late Animation<double> _bannerFloat;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    final session = SessionService.instance.getSession();
    _session  = session ?? const UserSession(
        username: 'Student', board: 'CBSE', className: 'Class 10');
    _subjects = CurriculumData.getSubjects(_session.board, _session.className);

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _owlCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _owlBob = Tween<double>(begin: 0, end: 8)
        .animate(CurvedAnimation(parent: _owlCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _streakCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _streakCount = Tween<double>(
            begin: 0,
            end: SessionService.instance.currentStreak.toDouble())
        .animate(CurvedAnimation(parent: _streakCtrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _streakCtrl.forward();
    });

    _bannerCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _bannerFloat = Tween<double>(begin: 0, end: 6)
        .animate(CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = SessionService.instance.getSession();
    if (session != null) {
      final newSubjects = CurriculumData.getSubjects(
          session.board, session.className);
      final newStreak   = SessionService.instance.currentStreak;
      if (mounted) {
        setState(() {
          _session  = session;
          _subjects = newSubjects;
        });
        _streakCtrl.reset();
        _streakCount = Tween<double>(begin: 0, end: newStreak.toDouble())
            .animate(CurvedAnimation(
                parent: _streakCtrl, curve: Curves.easeOutCubic));
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _streakCtrl.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _floatCtrl.dispose();
    _owlCtrl.dispose();
    _streakCtrl.dispose();
    _bannerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildBgBlobs(),
                  ..._buildParticles(),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 18),
                        _buildStreakBanner(),
                        const SizedBox(height: 18),
                        _buildToggle(),
                        const SizedBox(height: 22),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: _toggleIndex == 0
                              ? _buildStudyContent(key: const ValueKey('study'))
                              : _buildLanguagePage(key: const ValueKey('lang')),
                        ),
                        const SizedBox(height: 20),
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

  Widget _buildBgBlobs() {
    return IgnorePointer(
      child: Stack(children: [
        Positioned(top: -50, right: -50,
          child: Container(width: 180, height: 180,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.lavLight.withOpacity(0.6)))),
        Positioned(top: 200, left: -60,
          child: Container(width: 160, height: 160,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.mintA.withOpacity(0.4)))),
        Positioned(bottom: 80, right: -40,
          child: Container(width: 140, height: 140,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.blushA.withOpacity(0.35)))),
      ]),
    );
  }

  List<Widget> _buildParticles() {
    final items = [
      {'e': '⭐', 'lf': 0.06, 'tf': 0.10, 'ph': 0.0},
      {'e': '✏️', 'lf': 0.80, 'tf': 0.06, 'ph': 0.5},
      {'e': '📐', 'lf': 0.88, 'tf': 0.22, 'ph': 1.0},
      {'e': '💡', 'lf': 0.04, 'tf': 0.40, 'ph': 0.8},
      {'e': '🌸', 'lf': 0.85, 'tf': 0.48, 'ph': 0.3},
      {'e': '🎯', 'lf': 0.08, 'tf': 0.60, 'ph': 1.2},
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
            top: 600  * (item['tf'] as double) + dy,
            child: IgnorePointer(
              child: Opacity(opacity: 0.45,
                child: Text(item['e'] as String,
                    style: const TextStyle(fontSize: 18))),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.peachA,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('☀️  Good Morning',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.inkMid, letterSpacing: 0.4)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hey, ${_session.username}!',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                      color: AppColors.inkDark, height: 1.1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_session.board} · ${_session.className} 🚀',
                    style: const TextStyle(fontSize: 13,
                      color: AppColors.inkLight, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedBuilder(
              animation: _owlBob,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, -_owlBob.value),
                child: const _OwlMascot(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBanner() {
    return AnimatedBuilder(
      animation: _streakCount,
      builder: (_, __) {
        final count = _streakCount.value.round();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF9D9B8), Color(0xFFF5C6B8)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.peachB.withOpacity(0.45),
                blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: -0.12, end: 0.12),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                builder: (_, v, child) => Transform.rotate(angle: v, child: child),
                child: const Text('🔥', style: TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$count Day Streak!',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                        color: AppColors.inkDark)),
                    const Text('Keep it up, champion! 🏆',
                      style: TextStyle(fontSize: 11, color: AppColors.inkMid,
                        fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Row(
                children: List.generate(7, (i) => AnimatedContainer(
                  duration: Duration(milliseconds: 150 + i * 80),
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < count
                        ? AppColors.inkDark
                        : AppColors.inkDark.withOpacity(0.18),
                  ),
                )),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggle() {
    final toggleBg = _toggleIndex == 0 ? AppColors.lavLight : const Color(0xFFD0EDE4);
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
        child: IntrinsicWidth(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            height: 46,
            decoration: BoxDecoration(
              color: toggleBg,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(
                color: (_toggleIndex == 0 ? AppColors.lavMid : const Color(0xFF72B89A))
                    .withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 3),
              )],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToggleBtn(label: 'Study', emoji: '📚',
                  selected: _toggleIndex == 0, activeColor: Colors.white,
                  onTap: () => setState(() => _toggleIndex = 0)),
                _ToggleBtn(label: 'Language', emoji: '🌐',
                  selected: _toggleIndex == 1,
                  activeColor: const Color(0xFFB8E4D0),
                  onTap: () => setState(() => _toggleIndex = 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudyContent({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Subjects', badge: '${_subjects.length} subjects'),
        const SizedBox(height: 14),
        _buildSubjectsGrid(),
        const SizedBox(height: 22),
        _buildNotesBanner(),
        const SizedBox(height: 22),
        // ── Continue Watching header with "View more" button ──────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _SectionTitle(title: 'Continue Watching'),
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
                (route) => route.isFirst,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.lavLight,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lavMid.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('View more',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkMid,
                      )),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward_ios_rounded,
                      size: 9, color: AppColors.inkMid),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildVideoRow(),
      ],
    );
  }

  Widget _buildSubjectsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _subjects.length,
      itemBuilder: (ctx, i) {
        final subject = _subjects[i];
        final colors  = _colorFor(subject.emoji);
        return _SubjectCard(
          name:   subject.name,
          emoji:  subject.emoji,
          colorA: colors.$1,
          colorB: colors.$2,
          delay:  Duration(milliseconds: i * 60),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChapterPage(
                subjectName: subject.name,
                chapters:    subject.chapters,
                board:       _session.board,
                className:   _session.className,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesBanner() {
    return AnimatedBuilder(
      animation: _bannerFloat,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -_bannerFloat.value), child: child),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD8C8F0), Color(0xFFE8D8F8)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.lavMid.withOpacity(0.4),
              blurRadius: 18, offset: const Offset(0, 6))],
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('✨ Featured',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: AppColors.inkMid)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Best Study\nNotes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                      color: AppColors.inkDark, height: 1.2)),
                  const SizedBox(height: 6),
                  const Text('Get best notes for\nevery subject! 📝',
                    style: TextStyle(fontSize: 12, color: AppColors.inkMid, height: 1.4)),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(color: AppColors.inkDark,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.inkDark.withOpacity(0.2),
                            blurRadius: 10, offset: const Offset(0, 4))]),
                      child: const Text("Let's Explore 🚀",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final books = ['📗', '📘', '📕'];
                  return AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (_, __) {
                      final t  = (_floatCtrl.value + i * 0.28) % 1.0;
                      final dy = math.sin(t * math.pi * 2) * 5;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: Padding(padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(books[i], style: const TextStyle(fontSize: 30))));
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Fetches latest 2 watch-history entries and builds video cards ───────────
  Widget _buildVideoRow() {
    final history = SessionService.instance.getWatchHistory();
    final latest  = history.take(2).toList();

    // No history yet — show friendly placeholder cards
    if (latest.isEmpty) {
      return Row(children: [
        Expanded(
          child: _VideoCard(
            subject: 'Start Watching',
            emoji:   '▶️',
            colorA:  AppColors.lavLight,
            colorB:  AppColors.lavMid,
            delay:   Duration.zero,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _VideoCard(
            subject: 'Explore Topics',
            emoji:   '📚',
            colorA:  AppColors.mintA,
            colorB:  AppColors.mintB,
            delay:   const Duration(milliseconds: 120),
          ),
        ),
      ]);
    }

    // Build up to 2 cards; fill second slot with placeholder when only 1 entry
    final widgets = <Widget>[];
    for (int i = 0; i < 2; i++) {
      if (i > 0) widgets.add(const SizedBox(width: 14));

      if (i < latest.length) {
        final entry = latest[i];
        final meta  = _metaFor(entry.subject);
        widgets.add(
          Expanded(
            child: _VideoCard(
              subject: entry.topicTitle,
              emoji:   meta['e'] as String,
              colorA:  meta['c1'] as Color,
              colorB:  meta['c2'] as Color,
              delay:   Duration(milliseconds: i * 120),
            ),
          ),
        );
      } else {
        // Placeholder second card
        widgets.add(
          Expanded(
            child: _VideoCard(
              subject: 'Keep Going!',
              emoji:   '🎯',
              colorA:  AppColors.peachA,
              colorB:  AppColors.peachB,
              delay:   const Duration(milliseconds: 120),
            ),
          ),
        );
      }
    }

    return Row(children: widgets);
  }

  Widget _buildLanguagePage({Key? key}) {
    const Color gDark   = Color(0xFF4A8C6F);
    const Color gMid    = Color(0xFF72B89A);
    const Color gLight  = Color(0xFFB8E4D0);
    const Color gAccent = Color(0xFF9DD4B8);

    final languages = [
      {'flag': '🇰🇷', 'name': 'Korean',   'sub': 'K1 → K6',  'c1': const Color(0xFFB8E4D0), 'c2': const Color(0xFF9DD4B8)},
      {'flag': '🇯🇵', 'name': 'Japanese', 'sub': 'N5 → N1',  'c1': const Color(0xFFC8ECD8), 'c2': const Color(0xFFADD8C0)},
      {'flag': '🇩🇪', 'name': 'German',   'sub': 'A1 → B2',  'c1': const Color(0xFFD8F0E4), 'c2': const Color(0xFFBCDDD0)},
    ];
    final videosLang = [
      {'subject': 'Korean Basics', 'emoji': '🇰🇷', 'c1': const Color(0xFFB8E4D0), 'c2': const Color(0xFF9DD4B8)},
      {'subject': 'Japanese N5',   'emoji': '🇯🇵', 'c1': const Color(0xFFC8ECD8), 'c2': const Color(0xFFADD8C0)},
    ];

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _headerFade,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: gLight,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('🌿  Language Hub',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: gDark, letterSpacing: 0.4)),
                    ),
                    const SizedBox(height: 8),
                    Text('Learn a\nLanguage! 🌐',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                        color: gDark, height: 1.15)),
                    const SizedBox(height: 4),
                    Text('Pick a language and start today 🚀',
                      style: TextStyle(fontSize: 12, color: gMid, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedBuilder(
                animation: _owlBob,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, -_owlBob.value * 0.8),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [gLight, gMid],
                        begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: gMid.withOpacity(0.4),
                          blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: const Center(child: Text('🌍', style: TextStyle(fontSize: 38))),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: _streakCount,
          builder: (_, __) {
            final count = _streakCount.value.round();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [gLight, gAccent],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: gMid.withOpacity(0.4),
                    blurRadius: 14, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: -0.12, end: 0.12),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOut,
                    builder: (_, v, child) => Transform.rotate(angle: v, child: child),
                    child: const Text('🏅', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$count Words Learned!',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: gDark)),
                        Text('Keep practising daily! ✨',
                          style: TextStyle(fontSize: 11, color: gMid, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Row(children: List.generate(7, (i) => AnimatedContainer(
                    duration: Duration(milliseconds: 150 + i * 80),
                    width: 8, height: 8, margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: i < count ? gDark : gDark.withOpacity(0.18)),
                  ))),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        _GreenSectionTitle(title: 'Languages', badge: '3 available', gDark: gDark, gLight: gLight),
        const SizedBox(height: 14),
        Row(
          children: languages.asMap().entries.map((e) {
            final i = e.key; final lang = e.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 6, right: i == 2 ? 0 : 6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 350 + i * 80),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: _LangCard(
                    flag: lang['flag'] as String, name: lang['name'] as String,
                    sub: lang['sub'] as String, colorA: lang['c1'] as Color,
                    colorB: lang['c2'] as Color, gDark: gDark,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => LanguageChapterPage(languageName: lang['name'] as String))),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        AnimatedBuilder(
          animation: _bannerFloat,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, -_bannerFloat.value), child: child),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [gLight, const Color(0xFFD4EEE4)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: gMid.withOpacity(0.4),
                  blurRadius: 18, offset: const Offset(0, 6))],
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('🌟 Featured',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: gDark)),
                      ),
                      const SizedBox(height: 8),
                      Text('Best Language\nGuides',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                          color: gDark, height: 1.2)),
                      const SizedBox(height: 6),
                      Text('Curated lessons for\nevery level! 📚',
                        style: TextStyle(fontSize: 12, color: gMid, height: 1.4)),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(color: gDark,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: gDark.withOpacity(0.25),
                                blurRadius: 10, offset: const Offset(0, 4))]),
                          child: const Text("Let's Explore 🚀",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                              color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final items = ['🗣️', '📖', '✍️'];
                      return AnimatedBuilder(
                        animation: _floatCtrl,
                        builder: (_, __) {
                          final t  = (_floatCtrl.value + i * 0.28) % 1.0;
                          final dy = math.sin(t * math.pi * 2) * 5;
                          return Transform.translate(offset: Offset(0, dy),
                            child: Padding(padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(items[i], style: const TextStyle(fontSize: 30))));
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        _GreenSectionTitle(title: 'Continue Learning', gDark: gDark, gLight: gLight),
        const SizedBox(height: 14),
        Row(
          children: videosLang.asMap().entries.map((e) {
            final i = e.key; final v = e.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 14),
                child: _VideoCard(subject: v['subject'] as String,
                  emoji: v['emoji'] as String, colorA: v['c1'] as Color,
                  colorB: v['c2'] as Color, delay: Duration(milliseconds: i * 120)),
              ),
            );
          }).toList(),
        ),
      ],
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
        boxShadow: [BoxShadow(color: AppColors.lavMid.withOpacity(0.2),
            blurRadius: 16, offset: const Offset(0, -4))]),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = _bottomNavIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
              } else if (index == 2) {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                    (route) => route.isFirst);
              } else if (index == 3) {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                    (route) => route.isFirst);
              } else {
                setState(() => _bottomNavIndex = index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.lavLight : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.22 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: Icon(items[index]['icon'] as IconData, size: 24,
                      color: isActive ? AppColors.inkDark : AppColors.inkLight),
                  ),
                  const SizedBox(height: 3),
                  Text(items[index]['label'] as String,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.inkDark : AppColors.inkLight)),
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
// WIDGETS (unchanged from original)
// =============================================================================

class _OwlMascot extends StatelessWidget {
  const _OwlMascot();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(82, 92), painter: _OwlPainter());
}

class _OwlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawOval(Rect.fromCenter(center: Offset(w*.50,h*.67), width: w*.58, height: h*.58),
        Paint()..color = const Color(0xFFC9B8E8));
    canvas.drawOval(Rect.fromCenter(center: Offset(w*.50,h*.72), width: w*.38, height: h*.42),
        Paint()..color = const Color(0xFFEAE3F7));
    canvas.drawCircle(Offset(w*.50,h*.38), w*.30, Paint()..color = const Color(0xFFC9B8E8));
    final ear = Paint()..color = const Color(0xFFB8A6D9);
    canvas.drawPath(Path()..moveTo(w*.26,h*.20)..lineTo(w*.18,h*.04)..lineTo(w*.34,h*.15)..close(), ear);
    canvas.drawPath(Path()..moveTo(w*.74,h*.20)..lineTo(w*.82,h*.04)..lineTo(w*.66,h*.15)..close(), ear);
    canvas.drawCircle(Offset(w*.38,h*.36), w*.12, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w*.62,h*.36), w*.12, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w*.39,h*.37), w*.07, Paint()..color = const Color(0xFF3D3660));
    canvas.drawCircle(Offset(w*.63,h*.37), w*.07, Paint()..color = const Color(0xFF3D3660));
    canvas.drawCircle(Offset(w*.41,h*.35), w*.025, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w*.65,h*.35), w*.025, Paint()..color = Colors.white);
    canvas.drawPath(Path()..moveTo(w*.50,h*.46)..lineTo(w*.44,h*.53)..lineTo(w*.56,h*.53)..close(),
        Paint()..color = const Color(0xFFF9D9B8));
    final wing = Paint()..color = const Color(0xFFB8A6D9);
    canvas.save(); canvas.translate(w*.18,h*.68); canvas.rotate(-0.26);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w*.26, height: h*.34), wing);
    canvas.restore();
    canvas.save(); canvas.translate(w*.82,h*.68); canvas.rotate(0.26);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w*.26, height: h*.34), wing);
    canvas.restore();
    canvas.drawOval(Rect.fromCenter(center: Offset(w*.37,h*.94), width: w*.18, height: h*.09),
        Paint()..color = const Color(0xFFF9D9B8));
    canvas.drawOval(Rect.fromCenter(center: Offset(w*.63,h*.94), width: w*.18, height: h*.09),
        Paint()..color = const Color(0xFFF9D9B8));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.22,h*.13,w*.56,h*.08), const Radius.circular(3)),
        Paint()..color = const Color(0xFF3D3660));
    canvas.drawRect(Rect.fromLTWH(w*.46,h*.06,w*.08,h*.08), Paint()..color = const Color(0xFF3D3660));
    canvas.drawCircle(Offset(w*.50,h*.06), w*.06, Paint()..color = const Color(0xFFF9D9B8));
    canvas.drawLine(Offset(w*.76,h*.17), Offset(w*.76,h*.28),
        Paint()..color = const Color(0xFFF9D9B8)..strokeWidth = 1.5);
    canvas.drawCircle(Offset(w*.76,h*.30), w*.04, Paint()..color = const Color(0xFFF9D9B8));
  }
  @override bool shouldRepaint(_) => false;
}

class _ToggleBtn extends StatelessWidget {
  final String label, emoji;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;
  const _ToggleBtn({required this.label, required this.emoji,
    required this.selected, required this.onTap, this.activeColor});
  @override
  Widget build(BuildContext context) {
    final pillColor = activeColor ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), curve: Curves.easeOutBack,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? pillColor : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: selected ? [BoxShadow(color: pillColor.withOpacity(0.45),
              blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
            color: selected ? AppColors.inkDark : AppColors.inkLight)),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? badge;
  const _SectionTitle({required this.title, this.badge});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
          color: AppColors.inkDark, letterSpacing: -0.2)),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: AppColors.lavLight,
                borderRadius: BorderRadius.circular(20)),
            child: Text(badge!, style: const TextStyle(fontSize: 10,
              fontWeight: FontWeight.w700, color: AppColors.inkMid)),
          ),
        ],
      ]),
      const SizedBox(height: 5),
      Container(width: 50, height: 3,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.lavDark, AppColors.lavLight]),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ]);
  }
}

class _SubjectCard extends StatefulWidget {
  final String name, emoji;
  final Color colorA, colorB;
  final Duration delay;
  final VoidCallback onTap;
  const _SubjectCard({required this.name, required this.emoji,
    required this.colorA, required this.colorB,
    required this.delay, required this.onTap});
  @override State<_SubjectCard> createState() => _SubjectCardState();
}
class _SubjectCardState extends State<_SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _popIn;
  bool _pressed = false;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _popIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _popIn,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(scale: _pressed ? 0.91 : 1.0,
          duration: const Duration(milliseconds: 150), curve: Curves.easeOutBack,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [widget.colorA, widget.colorB],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: widget.colorB.withOpacity(0.4),
                blurRadius: _pressed ? 4 : 10, offset: Offset(0, _pressed ? 2 : 5))],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(widget.name, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                  color: AppColors.inkDark)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final String subject, emoji;
  final Color colorA, colorB;
  final Duration delay;
  const _VideoCard({required this.subject, required this.emoji,
    required this.colorA, required this.colorB, required this.delay});
  @override State<_VideoCard> createState() => _VideoCardState();
}
class _VideoCardState extends State<_VideoCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideIn;
  bool _pressed = false;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(_slideIn),
      child: FadeTransition(opacity: _slideIn,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), curve: Curves.easeOutBack,
            height: 115,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [widget.colorA, widget.colorB],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: widget.colorB.withOpacity(_pressed ? 0.2 : 0.35),
                blurRadius: _pressed ? 6 : 12, offset: Offset(0, _pressed ? 2 : 6))],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              AnimatedScale(scale: _pressed ? 0.9 : 1.0, duration: const Duration(milliseconds: 150),
                child: Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                        blurRadius: 8, offset: const Offset(0, 3))]),
                  child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 20))),
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 30, height: 30,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: AppColors.inkDark, size: 18)),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(widget.subject,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10,
                    fontWeight: FontWeight.w800, color: AppColors.inkDark)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _GreenSectionTitle extends StatelessWidget {
  final String title;
  final String? badge;
  final Color gDark, gLight;
  const _GreenSectionTitle({required this.title, required this.gDark,
    required this.gLight, this.badge});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
          color: gDark, letterSpacing: -0.2)),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: gLight, borderRadius: BorderRadius.circular(20)),
            child: Text(badge!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: gDark)),
          ),
        ],
      ]),
      const SizedBox(height: 5),
      Container(width: 50, height: 3,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [gDark, gLight]),
            borderRadius: BorderRadius.circular(2))),
    ]);
  }
}

class _LangCard extends StatefulWidget {
  final String flag, name, sub;
  final Color colorA, colorB, gDark;
  final VoidCallback? onTap;
  const _LangCard({required this.flag, required this.name, required this.sub,
    required this.colorA, required this.colorB, required this.gDark, this.onTap});
  @override State<_LangCard> createState() => _LangCardState();
}
class _LangCardState extends State<_LangCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(scale: _pressed ? 0.91 : 1.0,
        duration: const Duration(milliseconds: 150), curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.colorA, widget.colorB],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: widget.colorB.withOpacity(0.35),
              blurRadius: _pressed ? 4 : 10, offset: Offset(0, _pressed ? 2 : 5))],
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(widget.name, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: widget.gDark)),
            const SizedBox(height: 2),
            Text(widget.sub, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600,
                color: widget.gDark.withOpacity(0.6))),
          ]),
        ),
      ),
    );
  }
}