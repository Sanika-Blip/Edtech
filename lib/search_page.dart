import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color purpleDark   = Color(0xFF5B1F7A);
  static const Color purpleMid    = Color(0xFF7B2FA0);
  static const Color bgColor      = Color(0xFFF9F7FC);
  static const Color cardLight    = Color(0xFFCF9FE0);
  static const Color cardMid      = Color(0xFFB06FCC);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<String> _recommendations = [
    'Recommendation 1',
    'Recommendation 2',
    'Recommendation 3',
  ];

  final List<Map<String, dynamic>> _history = [
    {'label': 'Maths Chapter 3 - Algebra'},
    {'label': 'Science - Photosynthesis'},
    {'label': 'History - World War II'},
    {'label': 'Physics - Newton\'s Laws'},
    {'label': 'English - Grammar Rules'},
  ];

  final List<Map<String, dynamic>> _allSubjects = [
    {'name': 'Maths',     'icon': Icons.calculate_rounded},
    {'name': 'Science',   'icon': Icons.science_rounded},
    {'name': 'English',   'icon': Icons.menu_book_rounded},
    {'name': 'History',   'icon': Icons.account_balance_rounded},
    {'name': 'Geography', 'icon': Icons.public_rounded},
    {'name': 'Physics',   'icon': Icons.bolt_rounded},
    {'name': 'Chemistry', 'icon': Icons.biotech_rounded},
    {'name': 'Biology',   'icon': Icons.eco_rounded},
    {'name': 'Computer',  'icon': Icons.computer_rounded},
  ];

  List<Map<String, dynamic>> get _filteredResults {
    if (_query.isEmpty) return [];
    return _allSubjects
        .where((s) => s['name'].toString().toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Purple top bar with search ──────────────────────────────
            _buildTopBar(context),

            // ── Body ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _query.isNotEmpty
                    ? _buildSearchResults()
                    : _buildDefaultContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: purpleDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),

          // Search field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _query = val),
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          child: Icon(Icons.close_rounded, color: Colors.grey.shade500, size: 20),
                        )
                      : Icon(Icons.mic_rounded, color: Colors.grey.shade400, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Default content (no query) ────────────────────────────────────────────
  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recommendation chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _recommendations.map((rec) {
              final bool isFirst = rec == _recommendations.first;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    _searchController.text = rec;
                    setState(() => _query = rec);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isFirst ? Colors.white : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isFirst ? purpleDark : Colors.grey.shade300,
                        width: isFirst ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      rec,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isFirst ? purpleDark : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // History section
        _SectionTitle(title: 'History'),
        const SizedBox(height: 12),
        _buildHistoryList(),
      ],
    );
  }

  // ── History List ──────────────────────────────────────────────────────────
  Widget _buildHistoryList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _history.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey.shade200,
          indent: 52,
        ),
        itemBuilder: (context, index) {
          final item = _history[index];
          return ListTile(
            leading: Icon(
              Icons.access_time_rounded,
              color: Colors.grey.shade400,
              size: 22,
            ),
            title: Text(
              item['label'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
            onTap: () {
              _searchController.text = item['label'];
              setState(() => _query = item['label']);
            },
          );
        },
      ),
    );
  }

  // ── Search Results ────────────────────────────────────────────────────────
  Widget _buildSearchResults() {
    if (_filteredResults.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 60, color: cardLight),
              const SizedBox(height: 12),
              Text(
                'No results for "$_query"',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: purpleDark.withOpacity(0.5),
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
        Text(
          '${_filteredResults.length} result${_filteredResults.length > 1 ? 's' : ''} found',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredResults.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final subject = _filteredResults[index];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cardLight, cardMid],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(subject['icon'] as IconData, color: Colors.white, size: 22),
                ),
                title: Text(
                  subject['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                onTap: () {
                  // Navigate to chapter page
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (_) => ChapterPage(subjectName: subject['name']),
                  // ));
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// =============================================================================
// SECTION TITLE (local copy)
// =============================================================================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: Color(0xFF5B1F7A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}