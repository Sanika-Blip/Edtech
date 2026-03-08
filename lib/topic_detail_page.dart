import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TopicDetailPage extends StatefulWidget {
  final String topicTitle;
  const TopicDetailPage({super.key, required this.topicTitle});

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  int _bottomNavIndex = 0;
  YoutubePlayerController? _ytController;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _notes = [];
  bool _showNoteField = false;

  static const Color purpleDark  = Color(0xFF4A1070);
  static const Color purpleMid   = Color(0xFF7B2FA0);
  static const Color purpleLight = Color(0xFFB06FCC);
  static const Color purplePale  = Color(0xFFEDD6F7);
  static const Color bgColor     = Color(0xFFF9F7FC);

  // ✅ Khan Academy - embeddable educational video
  static const String _videoId = 'NybHckSEQBI';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _ytController = YoutubePlayerController(
          initialVideoId: _videoId,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ytController == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: purpleMid),
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _ytController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: purpleLight,
        progressColors: ProgressBarColors(
          playedColor: purpleMid,
          handleColor: purpleDark,
          bufferedColor: purplePale,
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
          backgroundColor: bgColor,
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // ── App Bar ───────────────────────────────────────────
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: purpleDark,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      centerTitle: true,
                      title: Text(
                        widget.topicTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft:  Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // ── YouTube Player ────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: player,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ── Video label badge ─────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: purplePale,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_circle_rounded,
                                      color: purpleMid, size: 14),
                                  const SizedBox(width: 5),
                                  Text('Video Lesson',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: purpleDark)),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Summary ───────────────────────────────────
                          _buildSummaryCard(),

                          const SizedBox(height: 20),

                          // ── Notes ─────────────────────────────────────
                          _buildNotesSection(),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        );
      },
    );
  }

  // ── Summary Card ───────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: purplePale,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: purpleDark.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [purpleLight, purpleDark]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Summary',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: purpleDark)),
            ]),
            const SizedBox(height: 14),
            Text(
              'In this topic, you will learn the fundamental concepts and their applications. '
              'Key points include understanding the core principles, practising with examples, '
              'and applying knowledge to solve real-world problems.\n\n'
              'By the end of this topic, you will be able to confidently answer questions '
              'related to ${widget.topicTitle} and build a strong foundation for upcoming topics.',
              style: TextStyle(
                  fontSize: 13.5,
                  color: purpleDark.withOpacity(0.75),
                  height: 1.6),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                '📌 Core Concepts', '🧠 Problem Solving',
                '📝 Examples',      '✅ Practice',
              ].map((tag) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: purpleDark.withOpacity(0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Text(tag,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: purpleDark)),
                  )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Notes Section ──────────────────────────────────────────────────────────
  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [purpleLight, purpleDark]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sticky_note_2_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text('My Notes',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: purpleDark)),
              ]),
              GestureDetector(
                onTap: () =>
                    setState(() => _showNoteField = !_showNoteField),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [purpleLight, purpleDark]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: purpleDark.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      _showNoteField
                          ? Icons.close_rounded
                          : Icons.add_rounded,
                      color: Colors.white, size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showNoteField ? 'Cancel' : 'Add Note',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (_showNoteField) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: purpleDark.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3)),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF1A1A2E)),
                  decoration: InputDecoration(
                    hintText: 'Write your note here...',
                    hintStyle: TextStyle(
                        color: Colors.grey[400], fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _saveNote,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 9),
                      decoration: BoxDecoration(
                        color: purpleDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),
          ],

          if (_notes.isEmpty && !_showNoteField)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: purplePale, width: 1.5),
              ),
              child: Column(children: [
                Icon(Icons.note_alt_outlined,
                    size: 40, color: purpleLight.withOpacity(0.5)),
                const SizedBox(height: 8),
                Text('No notes yet',
                    style: TextStyle(
                        color: purpleDark.withOpacity(0.4),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text('Tap "Add Note" to write something!',
                    style:
                        TextStyle(color: Colors.grey[400], fontSize: 11)),
              ]),
            )
          else
            ..._notes.asMap().entries.map(
                (e) => _buildNoteCard(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildNoteCard(int index, String note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: purpleDark.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
        border: Border(left: BorderSide(color: purpleMid, width: 3.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(note,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                    height: 1.5)),
          ),
          GestureDetector(
            onTap: () => setState(() => _notes.removeAt(index)),
            child: Icon(Icons.delete_outline_rounded,
                color: Colors.grey[400], size: 18),
          ),
        ],
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

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      Icons.home_rounded, Icons.search_rounded,
      Icons.access_time_rounded, Icons.person_rounded,
      Icons.settings_rounded,
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, -3)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final bool active = _bottomNavIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _bottomNavIndex = i),
            child: Icon(items[i],
                size: 26,
                color: active ? purpleDark : const Color(0xFFBBBBBB)),
          );
        }),
      ),
    );
  }
}