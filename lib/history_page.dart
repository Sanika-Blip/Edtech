import 'package:flutter/material.dart';
import 'search_page.dart';
import 'home1.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _bottomNavIndex = 2; // History tab is active
  int _tabIndex = 0; // 0 = Watch History, 1 = Watch Later

  static const Color purpleDark   = Color(0xFF5B1F7A);
  static const Color purpleMid    = Color(0xFF7B2FA0);
  static const Color bgColor      = Color(0xFFF9F7FC);
  static const Color purplePale   = Color(0xFFEDD6F7);

  // ── Watch History Data ────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _todayHistory = [
    {'subject': 'Maths',   'topic': 'Topic 6', 'chapter': 'Algebra Basics',    'duration': '12 min'},
    {'subject': 'Science', 'topic': 'Topic 6', 'chapter': 'Photosynthesis',     'duration': '18 min'},
    {'subject': 'English', 'topic': 'Topic 6', 'chapter': 'Grammar Essentials', 'duration': '9 min'},
  ];

  final List<Map<String, dynamic>> _last7DaysHistory = [
    {'subject': 'History',   'topic': 'Topic 6', 'chapter': 'World War II',    'duration': '22 min'},
    {'subject': 'Physics',   'topic': 'Topic 6', 'chapter': 'Newton\'s Laws',  'duration': '15 min'},
    {'subject': 'Chemistry', 'topic': 'Topic 6', 'chapter': 'Periodic Table',  'duration': '20 min'},
  ];

  // ── Watch Later Data ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _watchLater = [
    {'subject': 'Biology',   'topic': 'Topic 3', 'chapter': 'Cell Structure',  'duration': '14 min'},
    {'subject': 'Computer',  'topic': 'Topic 5', 'chapter': 'Data Structures', 'duration': '25 min'},
    {'subject': 'Geography', 'topic': 'Topic 2', 'chapter': 'Plate Tectonics', 'duration': '17 min'},
    {'subject': 'Maths',     'topic': 'Topic 8', 'chapter': 'Trigonometry',    'duration': '19 min'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _tabIndex == 0
                    ? _buildWatchHistory()
                    : _buildWatchLater(),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF1A1A2E), size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  ),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EDF7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Icon(Icons.search_rounded,
                            color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 8),
                        Text('Search...',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 14)),
                        const Spacer(),
                        Icon(Icons.mic_rounded,
                            color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            height: 40,
            decoration: BoxDecoration(
              color: purplePale,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _TabButton(
                  label: 'Watch History',
                  isSelected: _tabIndex == 0,
                  purpleDark: purpleDark,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                _TabButton(
                  label: 'Watch Later',
                  isSelected: _tabIndex == 1,
                  purpleDark: purpleDark,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Watch History ─────────────────────────────────────────────────────────
  Widget _buildWatchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Today'),
        const SizedBox(height: 12),
        _buildHistoryCard(_todayHistory),
        const SizedBox(height: 24),
        _buildSectionLabel('Last 7 Days'),
        const SizedBox(height: 12),
        _buildHistoryCard(_last7DaysHistory),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Watch Later ───────────────────────────────────────────────────────────
  Widget _buildWatchLater() {
    if (_watchLater.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_border_rounded, size: 60, color: purplePale),
              const SizedBox(height: 12),
              Text('No videos saved yet',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: purpleDark.withOpacity(0.4))),
              const SizedBox(height: 4),
              Text('Tap bookmark on any video to save it',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Saved Videos'),
        const SizedBox(height: 12),
        _buildHistoryCard(_watchLater),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1A2E),
        letterSpacing: -0.3,
      ),
    );
  }

  // ── History Card ──────────────────────────────────────────────────────────
  Widget _buildHistoryCard(List<Map<String, dynamic>> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B2FA0), Color(0xFFE8C8F5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: purpleDark.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          final bool isLast = item == items.last;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopicRow(item),
              if (!isLast) ...[
                const SizedBox(height: 10),
                Divider(color: Colors.white.withOpacity(0.2), height: 1),
                const SizedBox(height: 10),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Topic Row ─────────────────────────────────────────────────────────────
  Widget _buildTopicRow(Map<String, dynamic> item) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: purpleDark.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            item['topic'],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: purpleDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['chapter'],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${item['subject']} • ${item['duration']}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _tabIndex == 0
                ? Icons.play_arrow_rounded
                : Icons.bookmark_remove_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      Icons.home_rounded,
      Icons.search_rounded,
      Icons.access_time_rounded,
      Icons.person_rounded,
      Icons.settings_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final bool active = _bottomNavIndex == i;
          return GestureDetector(
            onTap: () {
              if (i == 0) {
                // ✅ Home — clears entire stack and goes to Home1Page fresh
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Home1Page()),
                  (route) => false,
                );
              } else if (i == 1) {
                // ✅ Search
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                );
              } else {
                setState(() => _bottomNavIndex = i);
              }
            },
            child: Icon(
              items[i],
              size: 26,
              color: active ? purpleDark : const Color(0xFFBBBBBB),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// TAB BUTTON
// =============================================================================
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color purpleDark;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.purpleDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? purpleDark : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF888888),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}