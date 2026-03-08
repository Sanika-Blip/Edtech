import 'package:flutter/material.dart';
import 'topic_map_page.dart';

class ChapterPage extends StatefulWidget {
  final String subjectName;

  const ChapterPage({super.key, required this.subjectName});

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  int _bottomNavIndex = 0;

  static const Color purpleDark   = Color(0xFF5B1F7A);
  static const Color purpleMid    = Color(0xFF7B2FA0);
  static const Color bgColor      = Color(0xFFF9F7FC);

  // Subject-wise chapters map
  final Map<String, List<Map<String, String>>> _subjectChapters = {
    'Maths': [
      {'title': 'Chapter 1: Basic Numbers',        'subtitle': 'Integers, fractions & decimals'},
      {'title': 'Chapter 2: Algebra Basics',       'subtitle': 'Variables, expressions & equations'},
      {'title': 'Chapter 3: Geometry',             'subtitle': 'Shapes, angles & theorems'},
      {'title': 'Chapter 4: Trigonometry',         'subtitle': 'Sin, cos, tan & identities'},
      {'title': 'Chapter 5: Statistics',           'subtitle': 'Mean, median, mode & graphs'},
    ],
    'Science': [
      {'title': 'Chapter 1: Matter & Materials',   'subtitle': 'States of matter & properties'},
      {'title': 'Chapter 2: Forces & Motion',      'subtitle': 'Newton\'s laws & energy'},
      {'title': 'Chapter 3: Light & Sound',        'subtitle': 'Waves, reflection & refraction'},
      {'title': 'Chapter 4: Living World',         'subtitle': 'Cell structure & life processes'},
      {'title': 'Chapter 5: Environment',          'subtitle': 'Ecosystem & conservation'},
    ],
    'English': [
      {'title': 'Chapter 1: Grammar Basics',       'subtitle': 'Nouns, verbs & adjectives'},
      {'title': 'Chapter 2: Reading Skills',       'subtitle': 'Comprehension & inference'},
      {'title': 'Chapter 3: Writing Skills',       'subtitle': 'Essays, letters & reports'},
      {'title': 'Chapter 4: Literature',           'subtitle': 'Prose, poetry & drama'},
      {'title': 'Chapter 5: Vocabulary',           'subtitle': 'Word formation & synonyms'},
    ],
    'History': [
      {'title': 'Chapter 1: Ancient Civilizations','subtitle': 'Indus Valley & Mesopotamia'},
      {'title': 'Chapter 2: Medieval Period',      'subtitle': 'Mughal empire & crusades'},
      {'title': 'Chapter 3: Colonial Era',         'subtitle': 'British rule & independence'},
      {'title': 'Chapter 4: World Wars',           'subtitle': 'WWI, WWII & consequences'},
      {'title': 'Chapter 5: Modern India',         'subtitle': 'Post-independence developments'},
    ],
    'Geography': [
      {'title': 'Chapter 1: Earth & Maps',         'subtitle': 'Latitude, longitude & projections'},
      {'title': 'Chapter 2: Landforms',            'subtitle': 'Mountains, plains & plateaus'},
      {'title': 'Chapter 3: Climate',              'subtitle': 'Weather patterns & seasons'},
      {'title': 'Chapter 4: Resources',            'subtitle': 'Natural resources & distribution'},
      {'title': 'Chapter 5: Population',           'subtitle': 'Demographics & urbanisation'},
    ],
    'Physics': [
      {'title': 'Chapter 1: Mechanics',            'subtitle': 'Motion, force & work'},
      {'title': 'Chapter 2: Thermodynamics',       'subtitle': 'Heat, temperature & laws'},
      {'title': 'Chapter 3: Electrostatics',       'subtitle': 'Charge, field & potential'},
      {'title': 'Chapter 4: Optics',               'subtitle': 'Lenses, mirrors & light'},
      {'title': 'Chapter 5: Modern Physics',       'subtitle': 'Atoms, nuclei & radiation'},
    ],
    'Chemistry': [
      {'title': 'Chapter 1: Atomic Structure',     'subtitle': 'Protons, electrons & orbitals'},
      {'title': 'Chapter 2: Periodic Table',       'subtitle': 'Elements, groups & periods'},
      {'title': 'Chapter 3: Chemical Bonding',     'subtitle': 'Ionic, covalent & metallic'},
      {'title': 'Chapter 4: Reactions',            'subtitle': 'Acids, bases & redox'},
      {'title': 'Chapter 5: Organic Chemistry',    'subtitle': 'Hydrocarbons & functional groups'},
    ],
    'Biology': [
      {'title': 'Chapter 1: Cell Biology',         'subtitle': 'Cell structure & organelles'},
      {'title': 'Chapter 2: Genetics',             'subtitle': 'DNA, genes & heredity'},
      {'title': 'Chapter 3: Human Body',           'subtitle': 'Organ systems & functions'},
      {'title': 'Chapter 4: Plant Kingdom',        'subtitle': 'Photosynthesis & reproduction'},
      {'title': 'Chapter 5: Ecology',              'subtitle': 'Food chains & biodiversity'},
    ],
    'Computer': [
      {'title': 'Chapter 1: Basics of Computing',  'subtitle': 'Hardware, software & OS'},
      {'title': 'Chapter 2: Programming',          'subtitle': 'Algorithms & flowcharts'},
      {'title': 'Chapter 3: Internet & Web',       'subtitle': 'Networking & web basics'},
      {'title': 'Chapter 4: Database',             'subtitle': 'SQL, tables & queries'},
      {'title': 'Chapter 5: Cyber Security',       'subtitle': 'Threats, safety & ethics'},
    ],
  };

  List<Map<String, String>> get _chapters {
    return _subjectChapters[widget.subjectName] ??
        _subjectChapters['Maths']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── App Bar ──────────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 70,
                  floating: true,
                  snap: true,
                  backgroundColor: purpleDark,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  centerTitle: true,
                  title: Text(
                    widget.subjectName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft:  Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  // Decorative background pattern
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [purpleDark, purpleMid],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft:  Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),
                        // Decorative blobs
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -10,
                          left: 30,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Chapter list ─────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chapter = _chapters[index];
                        return _ChapterCard(
                          chapterTitle: chapter['title']!,
                          subtitle: chapter['subtitle']!,
                          index: index,
                          purpleDark: purpleDark,
                          purpleMid: purpleMid,
                        );
                      },
                      childCount: _chapters.length,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom navigation ─────────────────────────────────────────
          _buildBottomNav(),
        ],
      ),
    );
  }

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
        children: List.generate(items.length, (index) {
          final bool isActive = _bottomNavIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _bottomNavIndex = index),
            child: Icon(
              items[index],
              size: 26,
              color: isActive ? purpleDark : const Color(0xFFBBBBBB),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// CHAPTER CARD
// =============================================================================
class _ChapterCard extends StatelessWidget {
  final String chapterTitle;
  final String subtitle;
  final int index;
  final Color purpleDark, purpleMid;

  const _ChapterCard({
    required this.chapterTitle,
    required this.subtitle,
    required this.index,
    required this.purpleDark,
    required this.purpleMid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail ─────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft:  Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    purpleDark.withOpacity(0.85),
                    purpleMid.withOpacity(0.7),
                    const Color(0xFFCF9FE0).withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background pattern
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    bottom: -10,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Chapter number badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4), width: 1),
                      ),
                      child: Text(
                        'Ch. ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Play icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.6), width: 2),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  // Subject icon bottom right
                  Positioned(
                    bottom: 12,
                    right: 14,
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white.withOpacity(0.4),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Title + Start button ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Chapter info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapterTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Start button
                GestureDetector(
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TopicMapPage(chapterTitle: chapterTitle),
    ),
  );
},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [purpleDark, purpleMid],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: purpleDark.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}