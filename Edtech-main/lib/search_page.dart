import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home1.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'chapter_page.dart';
import 'topic_map_page.dart';
import 'services/session_service.dart';
import 'data/curriculum_data.dart';
import 'models/curriculum_model.dart';

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
  static const roseA    = Color(0xFFF5C6D0);
  static const roseB    = Color(0xFFEAADB8);
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH RESULT MODEL
// ─────────────────────────────────────────────────────────────────────────────
enum _ResultType { subject, chapter, topic }

class _SearchResult {
  final _ResultType type;
  final String      title;
  final String      subtitle;
  final String      emoji;
  final Color       colorA;
  final Color       colorB;
  final String      subjectName;
  final List<Chapter>? chapters;
  final String?     chapterId;
  final String?     chapterTitle;
  final List<String>? topics;
  final String?     board;
  final String?     className;

  const _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colorA,
    required this.colorB,
    required this.subjectName,
    this.chapters,
    this.chapterId,
    this.chapterTitle,
    this.topics,
    this.board,
    this.className,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBJECT META
// ─────────────────────────────────────────────────────────────────────────────
const _kSubjectMeta = <String, Map<String, dynamic>>{
  'Maths':          {'emoji': '🔢', 'c1': _C.lavMid,  'c2': _C.lavDark},
  'Science':        {'emoji': '🧪', 'c1': _C.mintA,   'c2': _C.mintB},
  'English':        {'emoji': '📖', 'c1': _C.blushA,  'c2': _C.blushB},
  'History':        {'emoji': '🏛️', 'c1': _C.skyA,    'c2': _C.skyB},
  'Geography':      {'emoji': '🌍', 'c1': _C.peachA,  'c2': _C.peachB},
  'Physics':        {'emoji': '⚡', 'c1': _C.lemonA,  'c2': _C.lemonB},
  'Chemistry':      {'emoji': '🧬', 'c1': _C.lilacA,  'c2': _C.lilacB},
  'Biology':        {'emoji': '🌿', 'c1': _C.sagA,    'c2': _C.sagB},
  'Computer':       {'emoji': '💻', 'c1': _C.powderA, 'c2': _C.powderB},
  'Maths I':        {'emoji': '🔢', 'c1': _C.lavMid,  'c2': _C.lavDark},
  'Maths II':       {'emoji': '📐', 'c1': _C.skyA,    'c2': _C.skyB},
  'Science I':      {'emoji': '🧪', 'c1': _C.mintA,   'c2': _C.mintB},
  'Science II':     {'emoji': '🌿', 'c1': _C.sagA,    'c2': _C.sagB},
  'Social Science': {'emoji': '🏛️', 'c1': _C.peachA,  'c2': _C.peachB},
  'Hindi':          {'emoji': '🔤', 'c1': _C.roseA,   'c2': _C.roseB},
  'EVS':            {'emoji': '🌍', 'c1': _C.sagA,    'c2': _C.sagB},
};

Map<String, dynamic> _metaFor(String s) =>
    _kSubjectMeta[s] ?? {'emoji': '📚', 'c1': _C.lavMid, 'c2': _C.lavDark};

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH PAGE
// ─────────────────────────────────────────────────────────────────────────────
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  int _bottomNavIndex = 1;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Filter tab: 0 = All, 1 = Subjects, 2 = Chapters, 3 = Topics
  int _filterTab = 0;

  late AnimationController _headerCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  late final List<_SearchResult> _searchIndex;
  late final String _board;
  late final String _className;

  final List<Map<String, String>> _chips = [
    {'label': 'Trending 🔥', 'query': 'Maths'},
    {'label': 'Algebra',     'query': 'Algebra'},
    {'label': 'Biology',     'query': 'Biology'},
    {'label': 'Physics ⚡',  'query': 'Physics'},
  ];

  final List<Map<String, String>> _filterTabs = [
    {'label': 'All',      'emoji': '📚'},
    {'label': 'Subjects', 'emoji': '🎓'},
    {'label': 'Chapters', 'emoji': '📖'},
    {'label': 'Topics',   'emoji': '🔍'},
  ];

  // Session-based recent searches list
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _buildIndex();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  void _buildIndex() {
    final session = SessionService.instance.getSession();
    _board     = session?.board     ?? 'CBSE';
    _className = session?.className ?? 'Class 10';

    final subjects = CurriculumData.getSubjects(_board, _className);
    final index    = <_SearchResult>[];

    for (final subject in subjects) {
      final meta  = _metaFor(subject.name);
      final c1    = meta['c1'] as Color;
      final c2    = meta['c2'] as Color;
      final emoji = meta['emoji'] as String;

      index.add(_SearchResult(
        type:        _ResultType.subject,
        title:       subject.name,
        subtitle:    '${subject.chapters.length} chapters',
        emoji:       emoji,
        colorA:      c1,
        colorB:      c2,
        subjectName: subject.name,
        chapters:    subject.chapters,
        board:       _board,
        className:   _className,
      ));

      for (final chapter in subject.chapters) {
        index.add(_SearchResult(
          type:         _ResultType.chapter,
          title:        chapter.title,
          subtitle:     subject.name,
          emoji:        emoji,
          colorA:       c1,
          colorB:       c2,
          subjectName:  subject.name,
          chapterId:    chapter.id,
          chapterTitle: chapter.title,
          topics:       chapter.topics,
          board:        _board,
          className:    _className,
        ));

        for (final topic in chapter.topics) {
          index.add(_SearchResult(
            type:         _ResultType.topic,
            title:        topic,
            subtitle:     '${subject.name} › ${chapter.title}',
            emoji:        emoji,
            colorA:       c1,
            colorB:       c2,
            subjectName:  subject.name,
            chapterId:    chapter.id,
            chapterTitle: chapter.title,
            topics:       chapter.topics,
            board:        _board,
            className:    _className,
          ));
        }
      }
    }

    _searchIndex = index;
  }

  List<_SearchResult> get _filteredResults {
    if (_query.trim().isEmpty) return [];

    final q = _query.toLowerCase().trim();
    final results = _searchIndex.where((r) {
      final matchTitle    = r.title.toLowerCase().contains(q);
      final matchSubtitle = r.subtitle.toLowerCase().contains(q);
      if (!matchTitle && !matchSubtitle) return false;

      switch (_filterTab) {
        case 1: return r.type == _ResultType.subject;
        case 2: return r.type == _ResultType.chapter;
        case 3: return r.type == _ResultType.topic;
        default: return true;
      }
    }).toList();

    results.sort((a, b) {
      final aExact = a.title.toLowerCase() == q ? 0 : 1;
      final bExact = b.title.toLowerCase() == q ? 0 : 1;
      if (aExact != bExact) return aExact.compareTo(bExact);
      return a.type.index.compareTo(b.type.index);
    });

    return results;
  }

  // Saves a term to recent list (called from submit, chip tap, result tap)
  void _saveRecent(String term) {
    final t = term.trim();
    if (t.isEmpty) return;
    if (!_recentSearches.contains(t)) {
      _recentSearches.insert(0, t);
      if (_recentSearches.length > 8) _recentSearches.removeLast();
    }
  }

  // Called on keyboard "search" button or recent item tap
  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _query = query.trim();
      _saveRecent(query);
    });
  }

  // Called when user taps a result card — saves the result title then navigates
  void _navigateTo(_SearchResult result) {
    // Save the tapped result's title (not the partial query)
    setState(() => _saveRecent(result.title));
    switch (result.type) {
      case _ResultType.subject:
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChapterPage(
            subjectName: result.subjectName,
            chapters:    result.chapters,
            board:       result.board,
            className:   result.className,
          ),
        ));
        break;
      case _ResultType.chapter:
      case _ResultType.topic:
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => TopicMapPage(
            chapterTitle: result.chapterTitle ?? result.title,
            topics:       result.topics ?? [],
            chapterId:    result.chapterId ?? '',
            subjectName:  result.subjectName,
            board:        result.board ?? _board,
            className:    result.className ?? _className,
          ),
        ));
        break;
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _searchController.dispose();
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
                  Column(
                    children: [
                      _buildTopBar(),
                      _buildFilterTabs(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: _query.isNotEmpty
                              ? _buildSearchResults()
                              : _buildDefaultContent(),
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

  Widget _buildBgBlobs() {
    return IgnorePointer(child: Stack(children: [
      Positioned(top: -50, right: -50,
        child: Container(width: 180, height: 180,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: _C.lavLight.withOpacity(0.55)))),
      Positioned(top: 220, left: -50,
        child: Container(width: 150, height: 150,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: _C.mintA.withOpacity(0.35)))),
      Positioned(bottom: 80, right: -30,
        child: Container(width: 130, height: 130,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: _C.blushA.withOpacity(0.3)))),
    ]));
  }

  List<Widget> _buildParticles() {
    final items = [
      {'e': '🔍', 'lf': 0.05, 'tf': 0.10, 'ph': 0.0},
      {'e': '✏️', 'lf': 0.82, 'tf': 0.07, 'ph': 0.5},
      {'e': '📐', 'lf': 0.88, 'tf': 0.28, 'ph': 1.0},
      {'e': '💡', 'lf': 0.04, 'tf': 0.44, 'ph': 0.8},
      {'e': '🌸', 'lf': 0.86, 'tf': 0.55, 'ph': 0.3},
    ];
    return items.map((item) => AnimatedBuilder(
      animation: _floatCtrl,
      builder: (ctx, _) {
        final sw = MediaQuery.of(ctx).size.width;
        final t  = (_floatCtrl.value + (item['ph'] as double)) % 1.0;
        final dy = math.sin(t * math.pi) * 10.0;
        return Positioned(
          left: sw  * (item['lf'] as double),
          top:  680 * (item['tf'] as double) + dy,
          child: IgnorePointer(child: Opacity(opacity: 0.38,
            child: Text(item['e'] as String,
                style: const TextStyle(fontSize: 17)))));
      })).toList();
  }

  Widget _buildTopBar() {
    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC9B8E8), Color(0xFFEAD8F8)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: _C.inkDark, size: 20))),
              const SizedBox(width: 10),
              const Text('Discover  🔍',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                  color: _C.inkDark)),
              const Spacer(),
              if (_query.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(14)),
                  child: Text(
                    '${_filteredResults.length} found',
                    style: const TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w800, color: _C.inkDark))),
            ]),
            const SizedBox(height: 14),
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, child) => Transform.scale(
                scale: 1.0 + (_query.isEmpty
                    ? (_pulseCtrl.value - 0.5).abs() * 0.006
                    : 0),
                child: child),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: _C.lavMid.withOpacity(0.3),
                      blurRadius: 12, offset: const Offset(0, 4))]),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  textInputAction: TextInputAction.search,
                  onChanged: (val) => setState(() => _query = val),
                  onSubmitted: _submitSearch,
                  style: const TextStyle(fontSize: 14, color: _C.inkDark),
                  decoration: InputDecoration(
                    hintText: 'Search subjects, chapters, topics...',
                    hintStyle: const TextStyle(color: _C.inkLight, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: _C.lavDark, size: 22),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _C.lavLight, shape: BoxShape.circle),
                              child: const Icon(Icons.close_rounded,
                                  color: _C.inkDark, size: 16)))
                        : Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _C.peachA,
                              borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.mic_rounded,
                                color: _C.inkDark, size: 18)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final tab    = _filterTabs[i];
          final active = _filterTab == i;
          return GestureDetector(
            onTap: () => setState(() => _filterTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: active ? _C.inkDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                  color: active
                      ? _C.inkDark.withOpacity(0.2)
                      : _C.lavMid.withOpacity(0.15),
                  blurRadius: 8, offset: const Offset(0, 3))]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(tab['emoji']!, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(tab['label']!,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                    color: active ? Colors.white : _C.inkMid)),
              ])));
        }),
    );
  }

  // ── Default content: chips + recent searches ──────────────────────────────
  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _chips.asMap().entries.map((e) {
              final i    = e.key;
              final chip = e.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 350 + i * 70),
                curve: Curves.easeOutBack,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      _searchController.text = chip['query']!;
                      _submitSearch(chip['query']!);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: i == 0
                            ? const LinearGradient(
                                colors: [_C.lavMid, _C.lavDark])
                            : null,
                        color: i != 0 ? Colors.white : null,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(
                          color: i == 0
                              ? _C.lavMid.withOpacity(0.35)
                              : Colors.black.withOpacity(0.06),
                          blurRadius: 8, offset: const Offset(0, 3))]),
                      child: Text(chip['label']!,
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800,
                          color: i == 0 ? Colors.white : _C.inkMid)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 26),

        // Recent searches — always visible, empty state when none yet
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSectionTitle('Recent Searches 🕐'),
            if (_recentSearches.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _recentSearches.clear()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _C.blushA.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14)),
                  child: const Text('Clear all',
                    style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700, color: _C.inkMid))),
              ),
          ],
        ),
        const SizedBox(height: 14),
        _recentSearches.isNotEmpty
            ? _buildRecentList()
            : _buildEmptyRecent(),
      ],
    );
  }

  // ── Empty state for recent searches ───────────────────────────────────────
  Widget _buildEmptyRecent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _C.lavMid.withOpacity(0.12),
            blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, math.sin(_floatCtrl.value * math.pi) * 6),
            child: child),
          child: const Text('🔍', style: TextStyle(fontSize: 48))),
        const SizedBox(height: 14),
        const Text('No recent searches yet',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
            color: _C.inkDark)),
        const SizedBox(height: 6),
        const Text(
          'Search for a subject, chapter or topic\nand it will appear here!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: _C.inkLight)),
      ]),
    );
  }

  // ── Recent searches list ──────────────────────────────────────────────────
  Widget _buildRecentList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _C.lavMid.withOpacity(0.15),
            blurRadius: 12, offset: const Offset(0, 4))]),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentSearches.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: _C.lavLight, indent: 56),
        itemBuilder: (_, i) {
          final term = _recentSearches[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 250 + i * 40),
            curve: Curves.easeOut,
            builder: (_, v, child) => Opacity(opacity: v, child: child),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _C.lavLight,
                  borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Icon(Icons.history_rounded,
                    size: 18, color: _C.lavDark))),
              title: Text(term,
                style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: _C.inkDark)),
              trailing: GestureDetector(
                onTap: () => setState(() => _recentSearches.removeAt(i)),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: _C.lavLight.withOpacity(0.6),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: _C.inkLight))),
              onTap: () {
                _searchController.text = term;
                _submitSearch(term);
              },
            ),
          );
        }),
    );
  }

  // ── Subject grid ──────────────────────────────────────────────────────────
  Widget _buildSubjectGrid(List<_SearchResult> subjects) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: subjects.length,
      itemBuilder: (ctx, i) {
        final r = subjects[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + i * 55),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Opacity(opacity: v,
            child: Transform.translate(
                offset: Offset(0, 16 * (1 - v)), child: child)),
          child: _SubjectTile(
            name:   r.title,
            emoji:  r.emoji,
            colorA: r.colorA,
            colorB: r.colorB,
            onTap:  () => _navigateTo(r),
          ),
        );
      },
    );
  }

  // ── Full search results ────────────────────────────────────────────────────
  Widget _buildSearchResults() {
    final results = _filteredResults;

    if (results.isEmpty) {
      return SizedBox(
        height: 320,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, math.sin(_floatCtrl.value * math.pi) * 8),
                child: child),
              child: const Text('🔍', style: TextStyle(fontSize: 64))),
            const SizedBox(height: 14),
            const Text('Nothing found!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                color: _C.inkDark)),
            const SizedBox(height: 6),
            const Text('Try a different keyword 🤔',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: _C.inkLight)),
          ])));
    }

    final subjects = results.where((r) => r.type == _ResultType.subject).toList();
    final chapters = results.where((r) => r.type == _ResultType.chapter).toList();
    final topics   = results.where((r) => r.type == _ResultType.topic).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _C.lavLight, borderRadius: BorderRadius.circular(14)),
            child: Text(
              '${results.length} result${results.length > 1 ? 's' : ''} ✨',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                color: _C.inkDark))),
        ]),

        if (subjects.isNotEmpty && (_filterTab == 0 || _filterTab == 1)) ...[
          const SizedBox(height: 22),
          _buildSectionTitle('Subjects 🎓'),
          const SizedBox(height: 14),
          _buildSubjectGrid(subjects),
        ],

        if (chapters.isNotEmpty && (_filterTab == 0 || _filterTab == 2)) ...[
          const SizedBox(height: 22),
          _buildSectionTitle('Chapters 📖'),
          const SizedBox(height: 12),
          ...chapters.asMap().entries.map((e) =>
              _buildListResultCard(e.value, e.key)),
        ],

        if (topics.isNotEmpty && (_filterTab == 0 || _filterTab == 3)) ...[
          const SizedBox(height: 22),
          _buildSectionTitle('Topics 🔍'),
          const SizedBox(height: 12),
          ...topics.asMap().entries.map((e) =>
              _buildListResultCard(e.value, e.key)),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListResultCard(_SearchResult result, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 280 + index * 50),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v,
        child: Transform.translate(
            offset: Offset(0, 12 * (1 - v)), child: child)),
      child: _ResultCard(result: result, onTap: () => _navigateTo(result)));
  }

  Widget _buildSectionTitle(String title) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
        color: _C.inkDark, letterSpacing: -0.2)),
      const SizedBox(height: 5),
      Container(width: 50, height: 3,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_C.lavDark, _C.lavLight]),
          borderRadius: BorderRadius.circular(2))),
    ]);
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
              if (index == 0) {
                Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const Home1Page()),
                  (route) => false);
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
              ])));
        })));
  }
}

// =============================================================================
// SUBJECT TILE
// =============================================================================
class _SubjectTile extends StatefulWidget {
  final String name, emoji;
  final Color colorA, colorB;
  final VoidCallback onTap;
  const _SubjectTile({required this.name, required this.emoji,
    required this.colorA, required this.colorB, required this.onTap});
  @override State<_SubjectTile> createState() => _SubjectTileState();
}
class _SubjectTileState extends State<_SubjectTile> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              blurRadius: _pressed ? 4 : 10,
              offset: Offset(0, _pressed ? 2 : 5))]),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(widget.name, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                color: _C.inkDark)),
          ]))));
  }
}

// =============================================================================
// RESULT CARD  (list row for chapters and topics)
// =============================================================================
class _ResultCard extends StatefulWidget {
  final _SearchResult result;
  final VoidCallback  onTap;
  const _ResultCard({required this.result, required this.onTap});
  @override State<_ResultCard> createState() => _ResultCardState();
}
class _ResultCardState extends State<_ResultCard> {
  bool _pressed = false;

  Color get _typeColor {
    switch (widget.result.type) {
      case _ResultType.chapter: return _C.skyA;
      case _ResultType.topic:   return _C.mintA;
      default:                  return _C.lavLight;
    }
  }

  String get _typeLabel {
    switch (widget.result.type) {
      case _ResultType.chapter: return 'Chapter';
      case _ResultType.topic:   return 'Topic';
      default:                  return 'Subject';
    }
  }

  IconData get _typeIcon {
    switch (widget.result.type) {
      case _ResultType.chapter: return Icons.menu_book_rounded;
      case _ResultType.topic:   return Icons.lightbulb_outline_rounded;
      default:                  return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
        onTapCancel: ()  => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(
                color: widget.result.colorB.withOpacity(_pressed ? 0.12 : 0.22),
                blurRadius: _pressed ? 4 : 12,
                offset: Offset(0, _pressed ? 2 : 4))]),
            child: Row(children: [
              // Colour thumb
              Container(
                width: 64, height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.result.colorA, widget.result.colorB],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.result.emoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Icon(_typeIcon, size: 12,
                        color: _C.inkDark.withOpacity(0.6)),
                  ])),
              // Text info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _typeColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8)),
                        child: Text(_typeLabel,
                          style: const TextStyle(fontSize: 9,
                            fontWeight: FontWeight.w800, color: _C.inkMid))),
                      const SizedBox(height: 5),
                      Text(widget.result.title,
                        style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w800, color: _C.inkDark),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(widget.result.subtitle,
                        style: const TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w600, color: _C.inkLight),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]))),
              // Arrow
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: _C.inkDark))),
            ]),       // Row
          ),          // Container
        ),            // AnimatedScale
      ),              // GestureDetector
    );                // Padding
  }
}