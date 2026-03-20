import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'language_topic_map_page.dart';
import 'search_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GREEN PASTEL PALETTE  (language theme)
// ─────────────────────────────────────────────────────────────────────────────
class _G {
  static const bg        = Color(0xFFF2FAF6);   // near-white mint bg
  static const inkDark   = Color(0xFF2D6B4F);   // deep forest green
  static const inkMid    = Color(0xFF4E9070);   // mid sage
  static const inkLight  = Color(0xFF88BBA0);   // soft sage

  static const gDark     = Color(0xFF4A8C6F);
  static const gMid      = Color(0xFF72B89A);
  static const gLight    = Color(0xFFB8E4D0);
  static const gPale     = Color(0xFFE4F5EE);

  // Per-language card accent shades
  static const korA      = Color(0xFFB8E4D0);
  static const korB      = Color(0xFF9DD4B8);
  static const jpA       = Color(0xFFC8ECD8);
  static const jpB       = Color(0xFFADD8C0);
  static const deA       = Color(0xFFD8F0E4);
  static const deB       = Color(0xFFBCDDD0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-language meta  (header gradient + card accent + emoji)
// ─────────────────────────────────────────────────────────────────────────────
const _langMeta = <String, Map<String, dynamic>>{
  'Korean':   {'h1': _G.korA, 'h2': _G.korB, 'c1': _G.korA, 'c2': _G.korB, 'emoji': '🇰🇷'},
  'Japanese': {'h1': _G.jpA,  'h2': _G.jpB,  'c1': _G.jpA,  'c2': _G.jpB,  'emoji': '🇯🇵'},
  'German':   {'h1': _G.deA,  'h2': _G.deB,  'c1': _G.deA,  'c2': _G.deB,  'emoji': '🇩🇪'},
};

// ─────────────────────────────────────────────────────────────────────────────
// LANGUAGE CHAPTER PAGE
// ─────────────────────────────────────────────────────────────────────────────
class LanguageChapterPage extends StatefulWidget {
  final String languageName;
  const LanguageChapterPage({super.key, required this.languageName});

  @override
  State<LanguageChapterPage> createState() => _LanguageChapterPageState();
}

class _LanguageChapterPageState extends State<LanguageChapterPage>
    with TickerProviderStateMixin {
  int _bottomNavIndex = 0;

  late AnimationController _headerCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _listCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _pulseAnim;

  // ── Chapter data per language ───────────────────────────────────────────────
  final _langChapters = <String, List<Map<String, String>>>{
    'Korean': [
      {'title': 'Chapter 1: Hangul Basics',      'subtitle': 'Vowels, consonants & syllables'},
      {'title': 'Chapter 2: Greetings',           'subtitle': 'Hello, goodbye & politeness levels'},
      {'title': 'Chapter 3: Numbers & Time',      'subtitle': 'Native & Sino-Korean numbers'},
      {'title': 'Chapter 4: Daily Expressions',   'subtitle': 'Food, shopping & transport'},
      {'title': 'Chapter 5: Grammar Foundations', 'subtitle': 'Particles, tense & sentence order'},
    ],
    'Japanese': [
      {'title': 'Chapter 1: Hiragana & Katakana', 'subtitle': 'The two phonetic scripts'},
      {'title': 'Chapter 2: Basic Kanji',         'subtitle': 'Top 50 everyday kanji'},
      {'title': 'Chapter 3: Greetings & Phrases', 'subtitle': 'Formal & casual expressions'},
      {'title': 'Chapter 4: Verb Conjugation',    'subtitle': 'る-verbs, う-verbs & て-form'},
      {'title': 'Chapter 5: Reading Practice',    'subtitle': 'Short passages & comprehension'},
    ],
    'German': [
      {'title': 'Chapter 1: Alphabet & Sounds',   'subtitle': 'Umlauts, ß & pronunciation'},
      {'title': 'Chapter 2: Articles & Nouns',    'subtitle': 'Der, die, das & plural rules'},
      {'title': 'Chapter 3: Present Tense',       'subtitle': 'Regular & irregular verbs'},
      {'title': 'Chapter 4: Cases',               'subtitle': 'Nominative, accusative & dative'},
      {'title': 'Chapter 5: Everyday Vocabulary', 'subtitle': 'Numbers, colours & directions'},
    ],
  };

  List<Map<String, String>> get _chapters =>
      _langChapters[widget.languageName] ?? _langChapters['Korean']!;

  Map<String, dynamic> get _meta =>
      _langMeta[widget.languageName] ?? _langMeta['Korean']!;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.25), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _headerCtrl, curve: Curves.easeOutCubic));

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

  @override
  void dispose() {
    _headerCtrl.dispose();
    _floatCtrl.dispose();
    _listCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final Color h1 = _meta['h1'] as Color;
    final Color h2 = _meta['h2'] as Color;

    return Scaffold(
      backgroundColor: _G.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Animated header bar
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: _buildHeader(h1, h2),
              ),
            ),
            // Content
            Expanded(
              child: Stack(
                children: [
                  _buildBgBlobs(h1, h2),
                  ..._buildParticles(),
                  ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                    itemCount: _chapters.length,
                    itemBuilder: (ctx, i) {
                      final start = i * 0.15;
                      final end   = (start + 0.55).clamp(0.0, 1.0);
                      final anim  = CurvedAnimation(
                        parent: _listCtrl,
                        curve: Interval(start, end,
                            curve: Curves.easeOutCubic),
                      );
                      return AnimatedBuilder(
                        animation: anim,
                        builder: (_, child) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.35),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _LangChapterCard(
                          chapterTitle: _chapters[i]['title']!,
                          subtitle:     _chapters[i]['subtitle']!,
                          index:        i,
                          colorA:       _meta['c1'] as Color,
                          colorB:       _meta['c2'] as Color,
                          headerA:      h1,
                          headerB:      h2,
                          pulseAnim:    _pulseAnim,
                          langEmoji:    _meta['emoji'] as String,
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

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(Color h1, Color h2) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [h1, h2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: h2.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(
            top: -18, right: -18,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -14, left: 24,
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 10, right: 80,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content row
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 16, 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _G.inkDark, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 4),
                Text(
                  _meta['emoji'] as String,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.languageName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _G.inkDark,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        '${_chapters.length} Chapters',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _G.inkMid,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chapter count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          size: 14, color: _G.inkDark),
                      const SizedBox(width: 4),
                      Text(
                        '${_chapters.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _G.inkDark,
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

  // ── Background blobs ────────────────────────────────────────────────────────
  Widget _buildBgBlobs(Color h1, Color h2) {
    return IgnorePointer(
      child: Stack(children: [
        Positioned(
          top: 20, right: -50,
          child: Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: h1.withOpacity(0.25),
            ),
          ),
        ),
        Positioned(
          top: 260, left: -55,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _G.gLight.withOpacity(0.35),
            ),
          ),
        ),
        Positioned(
          bottom: 60, right: -35,
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _G.gMid.withOpacity(0.2),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Floating particles ──────────────────────────────────────────────────────
  List<Widget> _buildParticles() {
    final items = [
      {'e': '🌿', 'lf': 0.07, 'tf': 0.05, 'ph': 0.0},
      {'e': '✨', 'lf': 0.82, 'tf': 0.10, 'ph': 0.6},
      {'e': '🍃', 'lf': 0.88, 'tf': 0.35, 'ph': 1.1},
      {'e': '💬', 'lf': 0.04, 'tf': 0.52, 'ph': 0.4},
      {'e': '🌱', 'lf': 0.80, 'tf': 0.65, 'ph': 0.9},
    ];
    return items.map((item) {
      return AnimatedBuilder(
        animation: _floatCtrl,
        builder: (ctx, _) {
          final sw = MediaQuery.of(ctx).size.width;
          final t  = (_floatCtrl.value + (item['ph'] as double)) % 1.0;
          final dy = math.sin(t * math.pi) * 9.0;
          return Positioned(
            left: sw  * (item['lf'] as double),
            top:  620 * (item['tf'] as double) + dy,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.4,
                child: Text(item['e'] as String,
                    style: const TextStyle(fontSize: 17)),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  // ── Bottom nav (green active pill) ─────────────────────────────────────────
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
            color: _G.gMid.withOpacity(0.2),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // Green active pill instead of lavender
                color: isActive ? _G.gLight : Colors.transparent,
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
                      color: isActive ? _G.inkDark : _G.inkLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isActive ? _G.inkDark : _G.inkLight,
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
// LANGUAGE CHAPTER CARD
// =============================================================================
class _LangChapterCard extends StatefulWidget {
  final String chapterTitle;
  final String subtitle;
  final int    index;
  final Color  colorA, colorB;
  final Color  headerA, headerB;
  final Animation<double> pulseAnim;
  final String langEmoji;

  const _LangChapterCard({
    required this.chapterTitle,
    required this.subtitle,
    required this.index,
    required this.colorA,
    required this.colorB,
    required this.headerA,
    required this.headerB,
    required this.pulseAnim,
    required this.langEmoji,
  });

  @override
  State<_LangChapterCard> createState() => _LangChapterCardState();
}

class _LangChapterCardState extends State<_LangChapterCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        margin: const EdgeInsets.only(bottom: 18),
        transform: Matrix4.identity()
          ..translate(0.0, _pressed ? 2.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: widget.colorB.withOpacity(_pressed ? 0.15 : 0.30),
              blurRadius: _pressed ? 6 : 16,
              offset: Offset(0, _pressed ? 2 : 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ── Thumbnail ───────────────────────────────────────────────────────────────
  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft:  Radius.circular(22),
        topRight: Radius.circular(22),
      ),
      child: Container(
        width: double.infinity,
        height: 155,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.headerA,
              widget.headerB,
              widget.colorA.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative blobs
            Positioned(
              right: -22, top: -22,
              child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -10, bottom: -12,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 50, bottom: -14,
              child: Container(
                width: 55, height: 55,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Chapter badge (top-left)
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.7), width: 1),
                ),
                child: Text(
                  'Ch. ${widget.index + 1}',
                  style: const TextStyle(
                    color: _G.inkDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // Language flag emoji (top-right)
            Positioned(
              top: 12, right: 12,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(widget.langEmoji,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),

            // Pulsing play button (centre)
            Center(
              child: AnimatedBuilder(
                animation: widget.pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: widget.pulseAnim.value,
                  child: child,
                ),
                child: Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.80),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.headerB.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: _G.inkDark,
                    size: 30,
                  ),
                ),
              ),
            ),

            // Progress dots (bottom-right)
            Positioned(
              bottom: 12, right: 14,
              child: Row(
                children: List.generate(3, (i) => Container(
                  width: 6, height: 6,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 0
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.35),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer: title + Start button ────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Accent bar
          Container(
            width: 4, height: 38,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.colorA, widget.colorB],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chapterTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _G.inkDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _G.inkLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Start button (green)
          _GreenStartButton(
            colorA: widget.colorA,
            colorB: widget.colorB,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LanguageTopicMapPage(
                    chapterTitle: widget.chapterTitle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// GREEN START BUTTON
// =============================================================================
class _GreenStartButton extends StatefulWidget {
  final Color colorA, colorB;
  final VoidCallback onTap;
  const _GreenStartButton({
    required this.colorA,
    required this.colorB,
    required this.onTap,
  });

  @override
  State<_GreenStartButton> createState() => _GreenStartButtonState();
}

class _GreenStartButtonState extends State<_GreenStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 130));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.colorA, widget.colorB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.colorB.withOpacity(0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Start',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _G.inkDark,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 11, color: _G.inkDark),
            ],
          ),
        ),
      ),
    );
  }
}