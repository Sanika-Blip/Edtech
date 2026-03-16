import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home1.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'chapter_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARED PALETTE (matches home1_page & profile_page)
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
  int? _selectedCategory; // null = all

  late AnimationController _headerCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _chips = [
    {'label': 'Trending 🔥', 'query': 'Maths'},
    {'label': 'Algebra',     'query': 'Algebra'},
    {'label': 'Biology',     'query': 'Biology'},
    {'label': 'Physics ⚡',  'query': 'Physics'},
  ];

  final List<Map<String, dynamic>> _history = [
    {'label': 'Maths Chapter 3 – Algebra',    'emoji': '🔢'},
    {'label': 'Science – Photosynthesis',      'emoji': '🌿'},
    {'label': 'History – World War II',        'emoji': '🏛️'},
    {'label': 'Physics – Newton\'s Laws',      'emoji': '⚡'},
    {'label': 'English – Grammar Rules',       'emoji': '📖'},
  ];

  final List<Map<String, dynamic>> _allSubjects = [
    {'name': 'Maths',     'emoji': '🔢', 'c1': _C.lavMid,  'c2': _C.lavDark,  'cat': 0},
    {'name': 'Science',   'emoji': '🧪', 'c1': _C.mintA,   'c2': _C.mintB,    'cat': 1},
    {'name': 'English',   'emoji': '📖', 'c1': _C.blushA,  'c2': _C.blushB,   'cat': 0},
    {'name': 'History',   'emoji': '🏛️', 'c1': _C.skyA,    'c2': _C.skyB,     'cat': 2},
    {'name': 'Geography', 'emoji': '🌍', 'c1': _C.peachA,  'c2': _C.peachB,   'cat': 2},
    {'name': 'Physics',   'emoji': '⚡', 'c1': _C.lemonA,  'c2': _C.lemonB,   'cat': 1},
    {'name': 'Chemistry', 'emoji': '🧬', 'c1': _C.lilacA,  'c2': _C.lilacB,   'cat': 1},
    {'name': 'Biology',   'emoji': '🌿', 'c1': _C.sagA,    'c2': _C.sagB,     'cat': 1},
    {'name': 'Computer',  'emoji': '💻', 'c1': _C.powderA, 'c2': _C.powderB,  'cat': 0},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All',      'emoji': '📚'},
    {'label': 'Science',  'emoji': '🔬'},
    {'label': 'Arts',     'emoji': '🎨'},
    {'label': 'Social',   'emoji': '🌐'},
  ];

  List<Map<String, dynamic>> get _filteredResults {
    var list = _allSubjects;
    if (_selectedCategory != null) {
      list = list.where((s) => s['cat'] == _selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where((s) =>
              s['name'].toString().toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
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
    _searchController.dispose();
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
                      _buildCategoryRow(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: _query.isNotEmpty || _selectedCategory != null
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
          top: 220, left: -50,
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
              color: _C.blushA.withOpacity(0.3),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Floating particles ──────────────────────────────────────────────────
  List<Widget> _buildParticles() {
    final items = [
      {'e': '🔍', 'lf': 0.05, 'tf': 0.10, 'ph': 0.0},
      {'e': '✏️', 'lf': 0.82, 'tf': 0.07, 'ph': 0.5},
      {'e': '📐', 'lf': 0.88, 'tf': 0.28, 'ph': 1.0},
      {'e': '💡', 'lf': 0.04, 'tf': 0.44, 'ph': 0.8},
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Discover  🔍',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _C.inkDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Search field
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) => Transform.scale(
                  scale: 1.0 +
                      (_query.isEmpty
                          ? (_pulseCtrl.value - 0.5).abs() * 0.006
                          : 0),
                  child: child,
                ),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _C.lavMid.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    onChanged: (val) => setState(() => _query = val),
                    style: const TextStyle(
                        fontSize: 14, color: _C.inkDark),
                    decoration: InputDecoration(
                      hintText: 'Search subjects, topics...',
                      hintStyle: TextStyle(
                          color: _C.inkLight, fontSize: 13),
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
                                  color: _C.lavLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    color: _C.inkDark, size: 16),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _C.peachA,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.mic_rounded,
                                  color: _C.inkDark, size: 18),
                            ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category filter row ─────────────────────────────────────────────────
  Widget _buildCategoryRow() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final cat    = _categories[i];
          final catIdx = i == 0 ? null : i - 1;
          final active = _selectedCategory == catIdx;
          return GestureDetector(
            onTap: () =>
                setState(() => _selectedCategory = active ? null : catIdx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                color: active ? _C.inkDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: active
                        ? _C.inkDark.withOpacity(0.2)
                        : _C.lavMid.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat['emoji'],
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cat['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : _C.inkMid,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Default content ─────────────────────────────────────────────────────
  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _chips.asMap().entries.map((e) {
              final i   = e.key;
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
                      _searchController.text = chip['query'];
                      setState(() => _query = chip['query']);
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
                        boxShadow: [
                          BoxShadow(
                            color: i == 0
                                ? _C.lavMid.withOpacity(0.35)
                                : Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        chip['label'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: i == 0 ? Colors.white : _C.inkMid,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 26),

        // History
        _buildSectionTitle('Recent Searches 🕐'),
        const SizedBox(height: 14),
        _buildHistoryList(),
      ],
    );
  }

  // ── Subject grid ─────────────────────────────────────────────────────────
  Widget _buildSubjectGrid(List<Map<String, dynamic>> subjects) {
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
        final s = subjects[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + i * 55),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
                offset: Offset(0, 16 * (1 - v)), child: child),
          ),
          child: _SubjectTile(
            name:   s['name'],
            emoji:  s['emoji'],
            colorA: s['c1'],
            colorB: s['c2'],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChapterPage(subjectName: s['name'])),
            ),
          ),
        );
      },
    );
  }

  // ── History list ─────────────────────────────────────────────────────────
  Widget _buildHistoryList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _C.lavMid.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _history.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: _C.lavLight, indent: 56),
        itemBuilder: (_, index) {
          final item = _history[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 350 + index * 60),
            curve: Curves.easeOut,
            builder: (_, v, child) =>
                Opacity(opacity: v, child: child),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _C.lavLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(item['emoji'],
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              title: Text(
                item['label'],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _C.inkDark,
                ),
              ),
              trailing: const Icon(Icons.north_west_rounded,
                  size: 16, color: _C.inkLight),
              onTap: () {
                _searchController.text = item['label'];
                setState(() => _query = item['label']);
              },
            ),
          );
        },
      ),
    );
  }

  // ── Search results ───────────────────────────────────────────────────────
  Widget _buildSearchResults() {
    final results = _filteredResults;

    if (results.isEmpty) {
      return SizedBox(
        height: 320,
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
                child: const Text('🔍',
                    style: TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 14),
              const Text(
                'Nothing found!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _C.inkDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different keyword 🤔',
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _C.lavLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${results.length} result${results.length > 1 ? 's' : ''} ✨',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _C.inkDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildSubjectGrid(results),
      ],
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
// SUBJECT TILE  (card used in the grid)
// =============================================================================
class _SubjectTile extends StatefulWidget {
  final String name;
  final String emoji;
  final Color colorA;
  final Color colorB;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.name,
    required this.emoji,
    required this.colorA,
    required this.colorB,
    required this.onTap,
  });

  @override
  State<_SubjectTile> createState() => _SubjectTileState();
}

class _SubjectTileState extends State<_SubjectTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.91 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.colorA, widget.colorB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.colorB.withOpacity(0.4),
                blurRadius: _pressed ? 4 : 10,
                offset: Offset(0, _pressed ? 2 : 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                widget.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _C.inkDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}