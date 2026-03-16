import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:math' as math;
import 'search_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GREEN PASTEL PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class _LV {
  static const bg        = Color(0xFFF2FAF6);
  static const inkDark   = Color(0xFF2D6B4F);
  static const inkMid    = Color(0xFF4E9070);
  static const inkLight  = Color(0xFF88BBA0);

  static const gDark     = Color(0xFF4A8C6F);
  static const gMid      = Color(0xFF72B89A);
  static const gLight    = Color(0xFFB8E4D0);
  static const gPale     = Color(0xFFE4F5EE);

  static const node1A    = Color(0xFFB8E4D0);
  static const node1B    = Color(0xFF9DD4B8);
  static const node2A    = Color(0xFFC8ECD8);
  static const node2B    = Color(0xFFADD8C0);
  static const node3A    = Color(0xFF9DCFB4);
  static const node3B    = Color(0xFF7BBFA0);

  // Chip accent colours — green family
  static const chip1     = Color(0xFFB8E4D0); // mint
  static const chip2     = Color(0xFFC8ECD8); // sage
  static const chip3     = Color(0xFFD8F0E4); // pale
  static const chip4     = Color(0xFF9DD4B8); // medium mint
}

// ─────────────────────────────────────────────────────────────────────────────
// LANGUAGE VIDEO REGISTRY
// Maps lesson/topic title → YouTube video ID.
// Falls back to demo video if not found.
// ─────────────────────────────────────────────────────────────────────────────
class _LangVideoRegistry {
  static const String _fallback = 'NybHckSEQBI';

  static const Map<String, String> _map = {
    // ── Korean ─────────────────────────────────────────────────────────────
    'Lesson 1': 'NybHckSEQBI',
    'Lesson 2': 'NybHckSEQBI',
    'Lesson 3': 'NybHckSEQBI',
    'Lesson 4': 'NybHckSEQBI',
    // ── Add per-lesson IDs as you get them, e.g.:
    // 'Chapter 1: Hangul Basics – Lesson 1': 'YOUTUBE_ID_HERE',
    // 'Chapter 2: Greetings – Lesson 1':     'YOUTUBE_ID_HERE',
  };

  static String idFor(String topicTitle) =>
      _map[topicTitle] ?? _fallback;
}

// ─────────────────────────────────────────────────────────────────────────────
// LANGUAGE TOPIC DETAIL PAGE
// ─────────────────────────────────────────────────────────────────────────────
class LanguageTopicDetailPage extends StatefulWidget {
  final String topicTitle;
  const LanguageTopicDetailPage({super.key, required this.topicTitle});

  @override
  State<LanguageTopicDetailPage> createState() =>
      _LanguageTopicDetailPageState();
}

class _LanguageTopicDetailPageState extends State<LanguageTopicDetailPage>
    with TickerProviderStateMixin {
  int _bottomNavIndex = 0;

  // YouTube
  YoutubePlayerController? _ytController;

  // Notes
  final TextEditingController _noteController = TextEditingController();
  final List<String> _notes = [];
  bool _showNoteField = false;

  // Animation controllers
  late AnimationController _headerCtrl;
  late AnimationController _contentCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset>  _headerSlide;
  late Animation<double> _pulseAnim;

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

    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _ytController = YoutubePlayerController(
          initialVideoId: _LangVideoRegistry.idFor(widget.topicTitle),
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
            controlsVisibleAtStart: true,
            forceHD: false,
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _ytController?.dispose();
    _noteController.dispose();
    _headerCtrl.dispose();
    _contentCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Animation<double> _sectionAnim(double start, double end) =>
      CurvedAnimation(
        parent: _contentCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_ytController == null) {
      return Scaffold(
        backgroundColor: _LV.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: _LV.gMid,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading lesson...',
                style: TextStyle(
                  color: _LV.inkMid,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _ytController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: _LV.gMid,
        progressColors: ProgressBarColors(
          playedColor:     _LV.gDark,
          handleColor:     _LV.inkDark,
          bufferedColor:   _LV.gLight,
          backgroundColor: Colors.white24,
        ),
        topActions: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.topicTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: _LV.bg,
          body: SafeArea(
            child: Column(
              children: [
                // Animated header
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _buildHeader(),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: Stack(
                    children: [
                      _buildBgBlobs(),
                      ..._buildParticles(),
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Video player
                            _buildAnimSection(
                              _sectionAnim(0.0, 0.4),
                              _buildVideoSection(player),
                            ),
                            const SizedBox(height: 20),

                            // Key points chips
                            _buildAnimSection(
                              _sectionAnim(0.15, 0.55),
                              _buildKeyPoints(),
                            ),
                            const SizedBox(height: 20),

                            // Summary card
                            _buildAnimSection(
                              _sectionAnim(0.30, 0.70),
                              _buildSummaryCard(),
                            ),
                            const SizedBox(height: 20),

                            // Notes section
                            _buildAnimSection(
                              _sectionAnim(0.45, 0.85),
                              _buildNotesSection(),
                            ),
                            const SizedBox(height: 24),
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
      },
    );
  }

  // ── Section fade+slide wrapper ────────────────────────────────────────────
  Widget _buildAnimSection(Animation<double> anim, Widget child) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(anim),
          child: c,
        ),
      ),
      child: child,
    );
  }

  // ── Background blobs (green) ──────────────────────────────────────────────
  Widget _buildBgBlobs() {
    return IgnorePointer(
      child: Stack(children: [
        Positioned(
          top: -40, right: -40,
          child: Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _LV.gLight.withOpacity(0.55),
            ),
          ),
        ),
        Positioned(
          top: 280, left: -50,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _LV.gPale.withOpacity(0.6),
            ),
          ),
        ),
        Positioned(
          bottom: 80, right: -35,
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _LV.node2A.withOpacity(0.35),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Floating particles (language themed) ─────────────────────────────────
  List<Widget> _buildParticles() {
    final items = [
      {'e': '🌿', 'lf': 0.06, 'tf': 0.04, 'ph': 0.0},
      {'e': '💬', 'lf': 0.84, 'tf': 0.08, 'ph': 0.5},
      {'e': '✨', 'lf': 0.88, 'tf': 0.38, 'ph': 0.8},
      {'e': '🗣️', 'lf': 0.04, 'tf': 0.55, 'ph': 0.3},
      {'e': '🍃', 'lf': 0.80, 'tf': 0.65, 'ph': 1.0},
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
            top:  600 * (item['tf'] as double) + dy,
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

  // ── Header (green gradient) ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_LV.gLight, _LV.gMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _LV.gMid.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(top: -16, right: -16,
            child: Container(width: 90, height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(bottom: -12, left: 50,
            child: Container(width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 14, 14),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _LV.inkDark, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 2),
                const Text('🌿', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.topicTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _LV.inkDark,
                          letterSpacing: 0.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const Text(
                        'Lesson Detail  🌱',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _LV.inkMid,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bookmark button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bookmark_border_rounded,
                      color: _LV.inkDark, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Video section ─────────────────────────────────────────────────────────
  Widget _buildVideoSection(Widget player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video player card
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _LV.gMid.withOpacity(0.28),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: player,
          ),
        ),
        const SizedBox(height: 12),

        // Video label + duration row
        Row(
          children: [
            // Pulsing video badge
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) =>
                  Transform.scale(scale: _pulseAnim.value, child: child),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_LV.gPale, _LV.gLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _LV.gMid.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('▶', style: TextStyle(fontSize: 10, color: _LV.inkDark)),
                    SizedBox(width: 5),
                    Text(
                      'Video Lesson',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _LV.inkDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Duration badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _LV.node2A,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🕐', style: TextStyle(fontSize: 10)),
                  SizedBox(width: 4),
                  Text(
                    '~10 min',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _LV.inkMid,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Key points chips (language themed) ───────────────────────────────────
  Widget _buildKeyPoints() {
    final chips = [
      {'icon': '👂', 'label': 'Listening',    'c': _LV.chip1},
      {'icon': '🗣️', 'label': 'Speaking',     'c': _LV.chip2},
      {'icon': '✍️', 'label': 'Writing',       'c': _LV.chip3},
      {'icon': '📖', 'label': 'Vocabulary',    'c': _LV.chip4},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('📚', 'What you\'ll practise'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.asMap().entries.map((e) {
            final i    = e.key;
            final chip = e.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 350 + i * 80),
              curve: Curves.easeOutBack,
              builder: (_, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: chip['c'] as Color,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: (chip['c'] as Color).withOpacity(0.45),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(chip['icon'] as String,
                        style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      chip['label'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _LV.inkDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Summary card (green gradient) ────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_LV.gPale, _LV.gLight.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _LV.gMid.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('📖', 'Summary'),
          const SizedBox(height: 14),
          Text(
            'In this lesson, you will build a solid foundation in the core language skills. '
            'Key focus areas include pronunciation, vocabulary building, grammar patterns, '
            'and practical conversational phrases you can use right away.\n\n'
            'By the end of ${widget.topicTitle}, you will be confident using these concepts '
            'in real conversations and be ready for the next lesson.',
            style: const TextStyle(
              fontSize: 13.5,
              color: _LV.inkMid,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 16),
          // Green progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.25),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.7),
                valueColor: const AlwaysStoppedAnimation<Color>(_LV.gDark),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '1 of 4 lessons completed',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _LV.inkLight,
            ),
          ),
        ],
      ),
    );
  }

  // ── Notes section ─────────────────────────────────────────────────────────
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('📓', 'My Notes'),
            _LAddNoteButton(
              isOpen: _showNoteField,
              onTap: () =>
                  setState(() => _showNoteField = !_showNoteField),
            ),
          ],
        ),
        const SizedBox(height: 14),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: _showNoteField
              ? _buildNoteInput()
              : const SizedBox.shrink(),
        ),

        if (_notes.isEmpty && !_showNoteField)
          _buildEmptyNotes()
        else
          ..._notes.asMap().entries.map(
            (e) => _buildNoteCard(e.key, e.value),
          ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _LV.gMid.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, color: _LV.inkDark),
                decoration: InputDecoration(
                  hintText: 'Write your note here...',
                  hintStyle: TextStyle(
                      color: _LV.inkLight.withOpacity(0.7),
                      fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: _LSaveNoteButton(onTap: _saveNote),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildEmptyNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _LV.gLight, width: 1.5),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, math.sin(_floatCtrl.value * math.pi) * 5),
              child: child,
            ),
            child: const Text('📓', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 10),
          const Text(
            'No notes yet',
            style: TextStyle(
              color: _LV.inkMid,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap "Add Note" to write something!',
            style: TextStyle(color: _LV.inkLight, fontSize: 12),
          ),
        ],
      ),
    );
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _LV.gMid.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: const Border(
            left: BorderSide(color: _LV.gDark, width: 4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                note,
                style: const TextStyle(
                  fontSize: 13,
                  color: _LV.inkDark,
                  height: 1.5,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _notes.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _LV.node2A.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: _LV.inkMid, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    final text = _noteController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _notes.insert(0, text);
        _noteController.clear();
        _showNoteField = false;
      });
    }
  }

  // ── Section label helper (green icon bg) ─────────────────────────────────
  Widget _sectionLabel(String emoji, String title) {
    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_LV.gLight, _LV.gMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _LV.gMid.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _LV.inkDark,
            letterSpacing: -0.2,
          ),
        ),
      ],
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
            color: _LV.gMid.withOpacity(0.2),
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
                    MaterialPageRoute(
                        builder: (_) => const SearchPage()));
              } else if (index == 2) {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const HistoryPage()));
              } else if (index == 3) {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const ProfilePage()));
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
                color: isActive ? _LV.gLight : Colors.transparent,
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
                      color: isActive ? _LV.inkDark : _LV.inkLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isActive ? _LV.inkDark : _LV.inkLight,
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
// ADD NOTE BUTTON  (green variant)
// =============================================================================
class _LAddNoteButton extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onTap;
  const _LAddNoteButton({required this.isOpen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isOpen
                ? [_LV.node2A, _LV.node2B]   // sage green when cancel
                : [_LV.gLight, _LV.gMid],     // mint green when add
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isOpen ? _LV.node2B : _LV.gMid).withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              turns: isOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                isOpen ? Icons.close_rounded : Icons.add_rounded,
                color: _LV.inkDark,
                size: 16,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              isOpen ? 'Cancel' : 'Add Note',
              style: const TextStyle(
                color: _LV.inkDark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SAVE NOTE BUTTON  (green variant)
// =============================================================================
class _LSaveNoteButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LSaveNoteButton({required this.onTap});

  @override
  State<_LSaveNoteButton> createState() => _LSaveNoteButtonState();
}

class _LSaveNoteButtonState extends State<_LSaveNoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_LV.gLight, _LV.gMid],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _LV.gMid.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💾', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'Save Note',
                style: TextStyle(
                  color: _LV.inkDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}