// lib/topic_detail_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:hive/hive.dart';
import 'dart:math' as math;
import 'search_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'services/session_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
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
  static const blushA   = Color(0xFFF2C4CE);
  static const blushB   = Color(0xFFE8A8B5);
  static const peachA   = Color(0xFFF9D9B8);
}

// ─────────────────────────────────────────────────────────────────────────────
// VIDEO REGISTRY — add real YouTube IDs here
// ─────────────────────────────────────────────────────────────────────────────
class _VideoRegistry {
  static const _fallback = 'NybHckSEQBI';
  static const Map<String, String> _map = {
    // 'Real Numbers': 'YOUR_ID_HERE',
  };
  static String idFor(String title) => _map[title] ?? _fallback;
}

// ─────────────────────────────────────────────────────────────────────────────
// TOPIC DETAIL PAGE
// ─────────────────────────────────────────────────────────────────────────────
class TopicDetailPage extends StatefulWidget {
  final String topicTitle;
  final String? chapterId;
  final String? chapterTitle;
  final String? subjectName;
  final int?    topicIndex;
  final int?    totalTopics;
  final String? board;
  final String? className;
  final VoidCallback? onWatched; // fired when 2-min threshold is reached

  const TopicDetailPage({
    super.key,
    required this.topicTitle,
    this.chapterId,
    this.chapterTitle,
    this.subjectName,
    this.topicIndex,
    this.totalTopics,
    this.board,
    this.className,
    this.onWatched,
  });

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage>
    with TickerProviderStateMixin {
  int _bottomNavIndex = 0;

  // ── YouTube ──────────────────────────────────────────────────────────────────
  YoutubePlayerController? _ytController;

  // ── Watch-time (Timer-based — reliable) ─────────────────────────────────────
  static const int _thresholdSecs = 120; // 2 minutes
  int    _watchedSecs    = 0;
  bool   _watchedEnough  = false;
  bool   _callbackFired  = false;
  Timer? _watchTimer;

  // ── Notes ────────────────────────────────────────────────────────────────────
  final TextEditingController _noteCtrl = TextEditingController();
  List<String> _notes       = [];
  bool         _showNote    = false;
  late String  _noteKey;

  // ── Animations ───────────────────────────────────────────────────────────────
  late AnimationController _headerCtrl;
  late AnimationController _contentCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Note key — fully qualified to avoid collision
    _noteKey = 'note|${widget.board ?? ""}|${widget.className ?? ""}|'
        '${widget.subjectName ?? ""}|${widget.chapterId ?? ""}|'
        '${widget.topicIndex ?? 0}';

    _notes = _loadNotes();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _headerCtrl, curve: Curves.easeOutCubic));

    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Init YouTube controller after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctrl = YoutubePlayerController(
        initialVideoId: _VideoRegistry.idFor(widget.topicTitle),
        flags: const YoutubePlayerFlags(
          autoPlay: false, mute: false,
          enableCaption: true, controlsVisibleAtStart: true,
        ),
      );
      ctrl.addListener(_onYtStateChange);
      setState(() => _ytController = ctrl);
      // Start polling 500 ms after controller is assigned
      Future.delayed(const Duration(milliseconds: 500), _startTimer);
    });
  }

  // ── Timer: ticks every second, counts only while playing ──────────────────
  void _startTimer() {
    _watchTimer?.cancel();
    _watchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _callbackFired) {
        _watchTimer?.cancel();
        return;
      }
      if (_ytController?.value.playerState == PlayerState.playing) {
        _watchedSecs++;
        if (_watchedSecs % 5 == 0 && mounted) setState(() {}); // refresh badge

        if (_watchedSecs >= _thresholdSecs) {
          _watchTimer?.cancel();
          _callbackFired = true;
          if (mounted) setState(() => _watchedEnough = true);
          _onThresholdReached();
        }
      }
    });
  }

  // ── Called exactly once when threshold is reached ──────────────────────────
  void _onThresholdReached() {
    widget.onWatched?.call();
    SessionService.instance.recordWatchToday();
    SessionService.instance.recordWatchHistory(
      subject:        widget.subjectName   ?? 'Unknown',
      chapterTitle:   widget.chapterTitle  ?? widget.chapterId ?? 'Unknown',
      topicTitle:     widget.topicTitle,
      watchedSeconds: _watchedSecs,
    );
    _showSnack();
  }

  void _showSnack() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Text('🎉', style: TextStyle(fontSize: 18)),
        SizedBox(width: 10),
        Expanded(child: Text('Topic completed! Next topic unlocked.',
            style: TextStyle(fontWeight: FontWeight.w700))),
      ]),
      backgroundColor: const Color(0xFF5B1F7A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── YouTube listener — only used to refresh UI badge ──────────────────────
  void _onYtStateChange() {
    if (mounted) setState(() {});
  }

  // ── Notes ──────────────────────────────────────────────────────────────────
  List<String> _loadNotes() {
    try {
      final box = Hive.box('sessionBox');
      final raw = box.get(_noteKey) as String?;
      if (raw != null && raw.isNotEmpty) {
        return raw.split('||').where((s) => s.isNotEmpty).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveNotes() async {
    try {
      await Hive.box('sessionBox').put(_noteKey, _notes.join('||'));
    } catch (_) {}
  }

  void _addNote() {
    final text = _noteCtrl.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _notes.insert(0, text);
        _noteCtrl.clear();
        _showNote = false;
      });
      _saveNotes();
    }
  }

  void _deleteNote(int index) {
    setState(() => _notes.removeAt(index));
    _saveNotes();
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
    _ytController?.removeListener(_onYtStateChange);
    _ytController?.dispose();
    _noteCtrl.dispose();
    _headerCtrl.dispose();
    _contentCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Animation<double> _secAnim(double start, double end) =>
      CurvedAnimation(parent: _contentCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic));

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_ytController == null) {
      return Scaffold(
        backgroundColor: _P.bg,
        body: const Center(child: CircularProgressIndicator(
            color: _P.lavMid, strokeWidth: 3)),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _ytController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: _P.lavMid,
        progressColors: ProgressBarColors(
          playedColor:     _P.lavDark,
          handleColor:     _P.inkDark,
          bufferedColor:   _P.lavLight,
          backgroundColor: Colors.white24,
        ),
        topActions: [
          const SizedBox(width: 8),
          Expanded(child: Text(widget.topicTitle,
            style: const TextStyle(color: Colors.white, fontSize: 13,
                fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis)),
        ],
      ),
      builder: (ctx, player) => Scaffold(
        backgroundColor: _P.bg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(child: Column(children: [
          FadeTransition(opacity: _headerFade,
            child: SlideTransition(position: _headerSlide,
                child: _buildHeader())),
          Expanded(child: Stack(children: [
            _buildBlobs(),
            ..._buildParticles(),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _animWrap(_secAnim(0.0, 0.4), _buildVideoSection(player)),
                const SizedBox(height: 20),
                _animWrap(_secAnim(0.15, 0.55), _buildKeyPoints()),
                const SizedBox(height: 20),
                _animWrap(_secAnim(0.30, 0.70), _buildSummaryCard()),
                const SizedBox(height: 20),
                _animWrap(_secAnim(0.45, 0.85), _buildNotesSection()),
                SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom + 24),
              ]),
            ),
          ])),
          _buildBottomNav(),
        ])),
      ),
    );
  }

  Widget _animWrap(Animation<double> anim, Widget child) =>
      AnimatedBuilder(
        animation: anim,
        builder: (_, c) => FadeTransition(opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12), end: Offset.zero).animate(anim),
            child: c)),
        child: child,
      );

  Widget _buildBlobs() => IgnorePointer(child: Stack(children: [
    Positioned(top:-40,right:-40, child: Container(width:160,height:160,
      decoration: BoxDecoration(shape:BoxShape.circle,
        color:_P.lavLight.withOpacity(0.55)))),
    Positioned(top:280,left:-50, child: Container(width:140,height:140,
      decoration: BoxDecoration(shape:BoxShape.circle,
        color:_P.mintA.withOpacity(0.35)))),
    Positioned(bottom:80,right:-35, child: Container(width:120,height:120,
      decoration: BoxDecoration(shape:BoxShape.circle,
        color:_P.blushA.withOpacity(0.30)))),
  ]));

  List<Widget> _buildParticles() {
    const items = [
      ['✨',0.06,0.04,0.0],['📝',0.84,0.08,0.5],
      ['💡',0.88,0.38,0.8],['🌟',0.04,0.55,0.3],['🎯',0.80,0.65,1.0],
    ];
    return items.map((item) => AnimatedBuilder(
      animation: _floatCtrl,
      builder: (ctx, _) {
        final sw = MediaQuery.of(ctx).size.width;
        final t  = (_floatCtrl.value + (item[3] as double)) % 1.0;
        final dy = math.sin(t * math.pi) * 9.0;
        return Positioned(
          left: sw  * (item[1] as double),
          top:  600 * (item[2] as double) + dy,
          child: IgnorePointer(child: Opacity(opacity: 0.38,
            child: Text(item[0] as String,
                style: const TextStyle(fontSize: 17)))));
      })).toList();
  }

  Widget _buildHeader() {
    final progress = (_watchedSecs / _thresholdSecs).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_P.lavMid, _P.lavDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
        boxShadow: [BoxShadow(color: _P.lavDark.withOpacity(0.4),
            blurRadius: 16, offset: const Offset(0, 6))]),
      child: Stack(children: [
        Positioned(top:-16,right:-16, child: Container(width:90,height:90,
          decoration: BoxDecoration(color:Colors.white.withOpacity(0.12),
              shape:BoxShape.circle))),
        Positioned(bottom:-12,left:50, child: Container(width:60,height:60,
          decoration: BoxDecoration(color:Colors.white.withOpacity(0.08),
              shape:BoxShape.circle))),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 14, 14),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _P.inkDark, size: 20),
              onPressed: () => Navigator.maybePop(context)),
            const SizedBox(width: 2),
            const Text('🎓', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.topicTitle,
                  style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w900, color: _P.inkDark),
                  overflow: TextOverflow.ellipsis, maxLines: 1),
                Text('${widget.subjectName ?? ""} · ${widget.chapterTitle ?? ""}',
                  style: const TextStyle(fontSize: 10,
                    fontWeight: FontWeight.w600, color: _P.inkMid),
                  overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            )),
            // Watch progress badge
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                  scale: _watchedEnough ? 1.0 : _pulseAnim.value,
                  child: child),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _watchedEnough
                      ? const Color(0xFF5B1F7A)
                      : Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_watchedEnough ? '✅' : '⏱️',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    _watchedEnough
                        ? 'Done!'
                        : '${(_watchedSecs / 60).floor()}m ${_watchedSecs % 60}s',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: _watchedEnough ? Colors.white : _P.inkDark)),
                ])),
            ),
          ]),
        ),
        // Progress bar at bottom of header
        Positioned(left:0, right:0, bottom:0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28)),
            child: LinearProgressIndicator(
              value: progress, minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: AlwaysStoppedAnimation<Color>(
                _watchedEnough ? Colors.white : _P.lavLight)))),
      ]),
    );
  }

  // TABLET FIX: player inside LayoutBuilder with fixed 16:9 height
  Widget _buildVideoSection(Widget player) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LayoutBuilder(builder: (_, c) {
        final h = c.maxWidth * 9 / 16;
        return Container(
          width: c.maxWidth, height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: _P.lavDark.withOpacity(0.28),
                blurRadius: 20, offset: const Offset(0, 8))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22), child: player));
      }),
      const SizedBox(height: 12),
      Row(children: [
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) =>
              Transform.scale(scale: _pulseAnim.value, child: child),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_P.lavLight, _P.lavMid]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: _P.lavMid.withOpacity(0.35),
                  blurRadius: 8, offset: const Offset(0, 3))]),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('▶', style: TextStyle(fontSize: 10, color: _P.inkDark)),
              SizedBox(width: 5),
              Text('Video Lesson', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w800, color: _P.inkDark)),
            ])),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: _P.peachA,
              borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('🕐', style: TextStyle(fontSize: 10)),
            SizedBox(width: 4),
            Text('Watch 2 min to complete',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: _P.inkMid)),
          ])),
      ]),
    ]);
  }

  Widget _buildKeyPoints() {
    const chips = [
      ['📌','Core Concepts', _P.lavLight],
      ['🧠','Problem Solving',_P.mintA],
      ['📝','Examples',       _P.peachA],
      ['✅','Practice',        _P.blushA],
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('📚', "What you'll learn"),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8,
        children: chips.asMap().entries.map((e) {
          final i = e.key; final chip = e.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 350 + i * 80),
            curve: Curves.easeOutBack,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: chip[2] as Color,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(
                  color: (chip[2] as Color).withOpacity(0.45),
                  blurRadius: 8, offset: const Offset(0, 3))]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(chip[0] as String, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(chip[1] as String, style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w800, color: _P.inkDark)),
              ])));
        }).toList()),
    ]);
  }

  Widget _buildSummaryCard() {
    final progress = (_watchedSecs / _thresholdSecs).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_P.lavLight, Color(0xFFF0EAFA)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: _P.lavMid.withOpacity(0.30),
            blurRadius: 16, offset: const Offset(0, 6))]),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('📖', 'Summary'),
        const SizedBox(height: 14),
        Text(
          'In this topic you will learn the fundamental concepts of '
          '${widget.topicTitle} and their real-world applications. '
          'Watch the full video to unlock the next topic.',
          style: const TextStyle(fontSize: 13.5, color: _P.inkMid, height: 1.65)),
        const SizedBox(height: 16),
        // Real-time progress bar
        ClipRRect(borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress, minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.7),
            valueColor: AlwaysStoppedAnimation<Color>(
              _watchedEnough ? const Color(0xFF5B1F7A) : _P.lavDark))),
        const SizedBox(height: 6),
        Text(
          _watchedEnough
              ? '✅ Topic completed!'
              : '$_watchedSecs s / $_thresholdSecs s watched',
          style: const TextStyle(fontSize: 11,
            fontWeight: FontWeight.w600, color: _P.inkLight)),
      ]),
    );
  }

  Widget _buildNotesSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _sectionLabel('📓', 'My Notes'),
        _AddNoteBtn(isOpen: _showNote,
            onTap: () => setState(() => _showNote = !_showNote)),
      ]),
      const SizedBox(height: 14),
      AnimatedSize(
        duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic,
        child: _showNote ? _buildNoteInput() : const SizedBox.shrink()),
      if (_notes.isEmpty && !_showNote)
        _buildEmptyNotes()
      else
        ..._notes.asMap().entries.map((e) => _buildNoteCard(e.key, e.value)),
    ]);
  }

  Widget _buildNoteInput() {
    return Column(children: [
      Container(
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: _P.lavMid.withOpacity(0.2),
              blurRadius: 12, offset: const Offset(0, 4))]),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _noteCtrl, maxLines: 3,
            style: const TextStyle(fontSize: 13, color: _P.inkDark),
            decoration: InputDecoration(
              hintText: 'Write your note here...',
              hintStyle: TextStyle(color: _P.inkLight.withOpacity(0.7),
                  fontSize: 13),
              border: InputBorder.none)),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight,
            child: _SaveNoteBtn(onTap: _addNote)),
        ])),
      const SizedBox(height: 14),
    ]);
  }

  Widget _buildEmptyNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _P.lavLight, width: 1.5)),
      child: Column(children: [
        AnimatedBuilder(animation: _floatCtrl,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, math.sin(_floatCtrl.value * math.pi) * 5),
            child: child),
          child: const Text('📓', style: TextStyle(fontSize: 40))),
        const SizedBox(height: 10),
        const Text('No notes yet',
          style: TextStyle(color: _P.inkMid, fontWeight: FontWeight.w700,
            fontSize: 14)),
        const SizedBox(height: 4),
        const Text('Tap "Add Note" to write something!',
          style: TextStyle(color: _P.inkLight, fontSize: 12)),
      ]));
  }

  Widget _buildNoteCard(int index, String note) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _P.lavMid.withOpacity(0.18),
              blurRadius: 10, offset: const Offset(0, 3))],
          border: const Border(
              left: BorderSide(color: _P.lavDark, width: 4))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(note, style: const TextStyle(
              fontSize: 13, color: _P.inkDark, height: 1.5))),
          GestureDetector(
            onTap: () => _deleteNote(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _P.blushA.withOpacity(0.6), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                  color: _P.inkMid, size: 14))),
        ])));
  }

  Widget _sectionLabel(String emoji, String title) {
    return Row(children: [
      Container(width: 38, height: 38,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_P.lavMid, _P.lavDark],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: _P.lavDark.withOpacity(0.3),
              blurRadius: 8, offset: const Offset(0, 3))]),
        child: Center(child: Text(emoji,
            style: const TextStyle(fontSize: 18)))),
      const SizedBox(width: 10),
      Text(title, style: const TextStyle(fontSize: 18,
        fontWeight: FontWeight.w900, color: _P.inkDark, letterSpacing: -0.2)),
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
        boxShadow: [BoxShadow(color: _P.lavMid.withOpacity(0.2),
            blurRadius: 16, offset: const Offset(0, -4))]),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = _bottomNavIndex == i;
          return GestureDetector(
            onTap: () {
              if (i == 1) Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchPage()));
              else if (i == 2) Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()));
              else if (i == 3) Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
              else setState(() => _bottomNavIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? _P.lavLight : Colors.transparent,
                borderRadius: BorderRadius.circular(14)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedScale(scale: active ? 1.22 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Icon(items[i]['icon'] as IconData, size: 24,
                    color: active ? _P.inkDark : _P.inkLight)),
                const SizedBox(height: 3),
                Text(items[i]['label'] as String,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: active ? _P.inkDark : _P.inkLight)),
              ])));
        })));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD NOTE BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _AddNoteBtn extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onTap;
  const _AddNoteBtn({required this.isOpen, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: isOpen
              ? [_P.blushA, _P.blushB] : [_P.lavMid, _P.lavDark]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: (isOpen ? _P.blushB : _P.lavDark).withOpacity(0.35),
            blurRadius: 8, offset: const Offset(0, 3))]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedRotation(turns: isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: Icon(isOpen ? Icons.close_rounded : Icons.add_rounded,
              color: _P.inkDark, size: 16)),
          const SizedBox(width: 5),
          Text(isOpen ? 'Cancel' : 'Add Note',
            style: const TextStyle(color: _P.inkDark, fontSize: 12,
              fontWeight: FontWeight.w800)),
        ])));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SAVE NOTE BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _SaveNoteBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _SaveNoteBtn({required this.onTap});
  @override State<_SaveNoteBtn> createState() => _SaveNoteBtnState();
}
class _SaveNoteBtnState extends State<_SaveNoteBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double>   _s;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120));
    _s = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeIn));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  Future<void> _tap() async {
    await _c.forward(); await _c.reverse(); widget.onTap();
  }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _tap,
    child: ScaleTransition(scale: _s,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_P.lavMid, _P.lavDark]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: _P.lavDark.withOpacity(0.35),
              blurRadius: 8, offset: const Offset(0, 3))]),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Text('💾', style: TextStyle(fontSize: 14)),
          SizedBox(width: 6),
          Text('Save Note', style: TextStyle(color: _P.inkDark,
              fontWeight: FontWeight.w800, fontSize: 13)),
        ]))));
}