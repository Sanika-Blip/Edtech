// lib/history_page.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'search_page.dart';
import 'home1.dart';
import 'profile_page.dart';
import 'topic_detail_page.dart';
import 'services/session_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
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

// Subject → colour + emoji
const _subjectMeta = <String, Map<String, dynamic>>{
  'Maths':          {'c1': _C.lavMid,  'c2': _C.lavDark, 'e': '🔢'},
  'Science':        {'c1': _C.mintA,   'c2': _C.mintB,   'e': '🧪'},
  'English':        {'c1': _C.blushA,  'c2': _C.blushB,  'e': '📖'},
  'History':        {'c1': _C.skyA,    'c2': _C.skyB,    'e': '🏛️'},
  'Geography':      {'c1': _C.peachA,  'c2': _C.peachB,  'e': '🌍'},
  'Physics':        {'c1': _C.lemonA,  'c2': _C.lemonB,  'e': '⚡'},
  'Chemistry':      {'c1': _C.lilacA,  'c2': _C.lilacB,  'e': '🧬'},
  'Biology':        {'c1': _C.sagA,    'c2': _C.sagB,    'e': '🌿'},
  'Computer':       {'c1': _C.powderA, 'c2': _C.powderB, 'e': '💻'},
  'Maths I':        {'c1': _C.lavMid,  'c2': _C.lavDark, 'e': '🔢'},
  'Maths II':       {'c1': _C.skyA,    'c2': _C.skyB,    'e': '📐'},
  'Science I':      {'c1': _C.mintA,   'c2': _C.mintB,   'e': '🧪'},
  'Science II':     {'c1': _C.sagA,    'c2': _C.sagB,    'e': '🌿'},
  'Social Science': {'c1': _C.peachA,  'c2': _C.peachB,  'e': '🏛️'},
  'Hindi':          {'c1': _C.blushA,  'c2': _C.blushB,  'e': '🔤'},
  'EVS':            {'c1': _C.sagA,    'c2': _C.sagB,    'e': '🌍'},
};

Map<String, dynamic> _metaFor(String s) =>
    _subjectMeta[s] ?? {'c1': _C.lavMid, 'c2': _C.lavDark, 'e': '📚'};

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY PAGE
// ─────────────────────────────────────────────────────────────────────────────
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin, RouteAware {
  int _bottomNavIndex = 2;
  int _tabIndex       = 0;

  late List<WatchHistoryEntry> _all;
  late List<WatchHistoryEntry> _today;
  late List<WatchHistoryEntry> _older;

  int get _totalMins =>
      _all.fold(0, (s, e) => s + e.watchedSeconds) ~/ 60;

  late AnimationController _headerCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  @override
  void initState() {
    super.initState();
    _loadHistory();

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload every time this route becomes active (including first time)
    setState(_loadHistory);
  }

  void _loadHistory() {
    _all   = SessionService.instance.getWatchHistory();
    _today = _all.where((e) => e.isToday).toList();
    _older = _all.where((e) => !e.isToday).toList();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(child: Column(children: [
        Expanded(child: Stack(children: [
          _buildBlobs(),
          ..._buildParticles(),
          Column(children: [
            _buildTopBar(),
            _buildToggle(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0), end: Offset.zero,
                    ).animate(anim),
                    child: child)),
                child: SingleChildScrollView(
                  key: ValueKey(_tabIndex),
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                  child: _tabIndex == 0
                      ? _buildHistoryTab()
                      : _buildWatchLaterTab()),
              ),
            ),
          ]),
        ])),
        _buildBottomNav(),
      ])),
    );
  }

  Widget _buildBlobs() => IgnorePointer(child: Stack(children: [
    Positioned(top:-50,right:-50, child: Container(width:180,height:180,
      decoration: BoxDecoration(shape:BoxShape.circle,
        color:_C.lavLight.withOpacity(0.55)))),
    Positioned(top:240,left:-50, child: Container(width:150,height:150,
      decoration: BoxDecoration(shape:BoxShape.circle,
        color:_C.mintA.withOpacity(0.35)))),
    Positioned(bottom:80,right:-30, child: Container(width:130,height:130,
      decoration: BoxDecoration(shape:BoxShape.circle,
        color:_C.peachA.withOpacity(0.30)))),
  ]));

  List<Widget> _buildParticles() {
    const items = [
      ['📺',0.05,0.08,0.0],['⏰',0.82,0.06,0.5],
      ['🎬',0.87,0.25,1.0],['🔖',0.04,0.42,0.7],['🌸',0.86,0.55,0.3],
    ];
    return items.map((item) => AnimatedBuilder(
      animation: _floatCtrl,
      builder: (ctx, _) {
        final sw = MediaQuery.of(ctx).size.width;
        final t  = (_floatCtrl.value + (item[3] as double)) % 1.0;
        final dy = math.sin(t * math.pi) * 10.0;
        return Positioned(
          left: sw  * (item[1] as double),
          top:  680 * (item[2] as double) + dy,
          child: IgnorePointer(child: Opacity(opacity:0.38,
            child: Text(item[0] as String,
                style: const TextStyle(fontSize:17)))));
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
              bottomRight: Radius.circular(28))),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(width:36,height:36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: _C.inkDark, size: 20))),
              const SizedBox(width: 10),
              const Text('My History  🕐',
                style: TextStyle(fontSize:20, fontWeight:FontWeight.w900,
                  color:_C.inkDark)),
              const Spacer(),
              // Clear button
              GestureDetector(
                onTap: _confirmClear,
                child: Container(width:36,height:36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: _C.inkDark, size: 20))),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchPage())),
                child: Container(width:36,height:36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.search_rounded,
                      color: _C.inkDark, size: 20))),
            ]),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _Pill(emoji:'📺',
                label:'${_all.length} Videos', color:_C.lavLight),
              const SizedBox(width:10),
              _Pill(emoji:'📅',
                label:'${_today.length} Today', color:_C.peachA),
              const SizedBox(width:10),
              _Pill(emoji:'⏱️',
                label:'$_totalMins min', color:_C.mintA),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History',
          style: TextStyle(fontWeight: FontWeight.w800, color: _C.inkDark)),
        content: const Text(
          'This will permanently delete your watch history.',
          style: TextStyle(color: _C.inkMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
              style: TextStyle(color: _C.inkLight, fontWeight: FontWeight.w700))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B1F7A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
            child: const Text('Clear',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await SessionService.instance.clearWatchHistory();
      setState(_loadHistory);
    }
  }

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:20, vertical:14),
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 + (_pulseCtrl.value - 0.5).abs() * 0.004,
          child: child),
        child: Container(
          height: 46,
          decoration: BoxDecoration(color:_C.lavLight,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color:_C.lavMid.withOpacity(0.3),
                blurRadius:12,offset:const Offset(0,3))]),
          child: Row(children: [
            _ToggleBtn(label:'Watch History', emoji:'📺',
              selected: _tabIndex == 0,
              onTap: () => setState(() => _tabIndex = 0)),
            _ToggleBtn(label:'Watch Later', emoji:'🔖',
              selected: _tabIndex == 1,
              onTap: () => setState(() => _tabIndex = 1)),
          ]))));
  }

  // ── WATCH HISTORY TAB ───────────────────────────────────────────────────────
  Widget _buildHistoryTab() {
    if (_all.isEmpty) {
      return _emptyState('📺', 'No watch history yet!',
          'Watch a video for 2+ minutes and it will appear here.');
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_today.isNotEmpty) ...[
        _sectionTitle('Today 🌤️'),
        const SizedBox(height: 14),
        ..._today.asMap().entries.map((e) => _card(e.value, e.key)),
        const SizedBox(height: 24),
      ],
      if (_older.isNotEmpty) ...[
        _sectionTitle('Earlier 📅'),
        const SizedBox(height: 14),
        ..._older.asMap().entries
            .map((e) => _card(e.value, e.key + _today.length)),
      ],
      const SizedBox(height: 16),
    ]);
  }

  // ── WATCH LATER TAB (placeholder) ───────────────────────────────────────────
  Widget _buildWatchLaterTab() => _emptyState(
      '🔖', 'Nothing saved yet!',
      'Tap bookmark on any video to save it 📌');

  Widget _emptyState(String emoji, String title, String subtitle) {
    return SizedBox(height: 340, child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(animation: _floatCtrl,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, math.sin(_floatCtrl.value * math.pi) * 8),
            child: child),
          child: Text(emoji, style: const TextStyle(fontSize: 64))),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18,
          fontWeight: FontWeight.w900, color: _C.inkDark)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: _C.inkLight)),
      ])));
  }

  Widget _card(WatchHistoryEntry entry, int index) {
    final meta  = _metaFor(entry.subject);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v,
        child: Transform.translate(
            offset: Offset(0, 18*(1-v)), child: child)),
      child: _HistoryCard(
        entry:     entry,
        emoji:     meta['e'] as String,
        c1:        meta['c1'] as Color,
        c2:        meta['c2'] as Color,
        floatCtrl: _floatCtrl,
        phase:     index * 0.18));
  }

  Widget _sectionTitle(String t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(t, style: const TextStyle(fontSize:18, fontWeight:FontWeight.w900,
        color:_C.inkDark, letterSpacing:-0.2)),
      const SizedBox(height:5),
      Container(width:50,height:3, decoration: BoxDecoration(
        gradient: const LinearGradient(colors:[_C.lavDark,_C.lavLight]),
        borderRadius: BorderRadius.circular(2))),
      const SizedBox(height:2),
    ]);

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
        boxShadow: [BoxShadow(color:_C.lavMid.withOpacity(0.2),
            blurRadius:16,offset:const Offset(0,-4))]),
      padding: const EdgeInsets.symmetric(vertical:10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = _bottomNavIndex == i;
          return GestureDetector(
            onTap: () {
              if (i == 0) Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const Home1Page()),
                (r) => false);
              else if (i == 1) Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchPage()));
              else if (i == 3) Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
              else setState(() => _bottomNavIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds:250),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal:12,vertical:6),
              decoration: BoxDecoration(
                color: active ? _C.lavLight : Colors.transparent,
                borderRadius: BorderRadius.circular(14)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedScale(scale: active ? 1.22 : 1.0,
                  duration: const Duration(milliseconds:250),
                  curve: Curves.easeOutBack,
                  child: Icon(items[i]['icon'] as IconData, size:24,
                    color: active ? _C.inkDark : _C.inkLight)),
                const SizedBox(height:3),
                Text(items[i]['label'] as String,
                  style: TextStyle(fontSize:9, fontWeight:FontWeight.w700,
                    color: active ? _C.inkDark : _C.inkLight)),
              ])));
        })));
  }
}

// =============================================================================
// HISTORY CARD
// =============================================================================
class _HistoryCard extends StatefulWidget {
  final WatchHistoryEntry  entry;
  final String             emoji;
  final Color              c1, c2;
  final AnimationController floatCtrl;
  final double             phase;
  const _HistoryCard({required this.entry, required this.emoji,
    required this.c1, required this.c2,
    required this.floatCtrl, required this.phase});
  @override State<_HistoryCard> createState() => _HistoryCardState();
}
class _HistoryCardState extends State<_HistoryCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom:12),
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) {
          setState(() => _pressed = false);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => TopicDetailPage(
              topicTitle:   widget.entry.topicTitle,
              chapterTitle: widget.entry.chapterTitle,
              subjectName:  widget.entry.subject,
            ),
          ));
        },
        onTapCancel: ()  => setState(() => _pressed = false),
        child: AnimatedScale(scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds:150),
          curve: Curves.easeOutBack,
          child: Container(
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(
                color: widget.c2.withOpacity(0.35),
                blurRadius: _pressed ? 4 : 12,
                offset: Offset(0, _pressed ? 2 : 5))]),
            child: Row(children: [
              // Thumbnail
              Container(
                width:72, height:80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:[widget.c1,widget.c2],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(animation: widget.floatCtrl,
                      builder: (_, child) {
                        final t  = (widget.floatCtrl.value+widget.phase) % 1.0;
                        final dy = math.sin(t*math.pi)*4;
                        return Transform.translate(
                            offset: Offset(0,-dy),child:child);
                      },
                      child: Text(widget.emoji,
                          style: const TextStyle(fontSize:22))),
                    const SizedBox(height:5),
                    Container(width:24,height:24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Color(0xFF3D3660), size:14)),
                  ])),
              // Info
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:14,vertical:12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal:9,vertical:3),
                      decoration: BoxDecoration(
                        color: widget.c1.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(10)),
                      child: Text(widget.entry.topicTitle,
                        style: const TextStyle(fontSize:9,
                          fontWeight:FontWeight.w800,
                          color: Color(0xFF3D3660)),
                        maxLines:1,overflow:TextOverflow.ellipsis)),
                    const SizedBox(height:6),
                    Text(widget.entry.chapterTitle,
                      style: const TextStyle(fontSize:13,
                        fontWeight:FontWeight.w800,
                        color: Color(0xFF3D3660)),
                      maxLines:1,overflow:TextOverflow.ellipsis),
                    const SizedBox(height:3),
                    Row(children: [
                      Text(widget.entry.subject,
                        style: const TextStyle(fontSize:11,
                          fontWeight:FontWeight.w600,
                          color: Color(0xFF6B6490))),
                      const SizedBox(width:6),
                      Container(width:3,height:3,
                        decoration: const BoxDecoration(
                          shape:BoxShape.circle,
                          color: Color(0xFF9E9BBF))),
                      const SizedBox(width:6),
                      Text(widget.entry.durationLabel,
                        style: const TextStyle(fontSize:11,
                          fontWeight:FontWeight.w600,
                          color: Color(0xFF9E9BBF))),
                    ]),
                    if (!widget.entry.isToday) ...[
                      const SizedBox(height:3),
                      Text(widget.entry.dateStr,
                        style: const TextStyle(fontSize:9,
                          fontWeight:FontWeight.w600,
                          color: Color(0xFF9E9BBF))),
                    ],
                  ]))),
              // Completed badge
              Padding(
                padding: const EdgeInsets.only(right:14),
                child: Container(width:34,height:34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B1F7A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.check_circle_outline_rounded,
                    color: Color(0xFF5B1F7A), size:18))),
            ]),
          ))));
  }
}

// =============================================================================
// TOGGLE BUTTON
// =============================================================================
class _ToggleBtn extends StatelessWidget {
  final String label, emoji;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.emoji,
    required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds:250),
        curve: Curves.easeOutBack,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical:7),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: selected ? [BoxShadow(
            color: _C.lavMid.withOpacity(0.3),
            blurRadius:8,offset:const Offset(0,2))] : []),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize:14)),
          const SizedBox(width:5),
          Text(label, style: TextStyle(fontSize:12,
            fontWeight:FontWeight.w800,
            color: selected ? _C.inkDark : _C.inkLight)),
        ]))));
}

// =============================================================================
// STAT PILL
// =============================================================================
class _Pill extends StatelessWidget {
  final String emoji, label;
  final Color color;
  const _Pill({required this.emoji, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal:12,vertical:6),
    decoration: BoxDecoration(color:color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color:color.withOpacity(0.4),
          blurRadius:8,offset:const Offset(0,3))]),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize:13)),
      const SizedBox(width:5),
      Text(label, style: const TextStyle(fontSize:11,
        fontWeight:FontWeight.w800, color: _C.inkDark)),
    ]));
}