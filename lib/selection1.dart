// selection1.dart  (updated — replaces your existing file)
// Only change vs original: saves board + class to SessionService on Continue.

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'services/session_service.dart';
import 'home1.dart';

class Selection1Page extends StatefulWidget {
  const Selection1Page({super.key});

  @override
  State<Selection1Page> createState() => _Selection1PageState();
}

class _Selection1PageState extends State<Selection1Page> {
  static const Color purpleDark   = Color(0xFF5B1F7A);
  static const Color purpleMid    = Color(0xFF7B2FA0);
  static const Color bgColor      = Color(0xFFF9F7FC);

  String? _selectedBoard;
  String? _selectedClass;

  final List<String> _boards = ['CBSE', 'SSC', 'HSC', 'ICSE'];

  final List<String> _classes = [
    'Class 1',  'Class 2',  'Class 3',  'Class 4',
    'Class 5',  'Class 6',  'Class 7',  'Class 8',
    'Class 9',  'Class 10', 'Class 11', 'Class 12',
  ];

  // ── The only added logic: save selection then navigate ──────────────────────
  Future<void> _onContinue() async {
    if (_selectedBoard == null || _selectedClass == null) return;

    // Matches your login code: box.put('username', enteredUser)
    final username = Hive.box('userBox').get('username') as String? ?? 'Student';

    await SessionService.instance.saveSelection(
      username:  username,
      board:     _selectedBoard!,
      className: _selectedClass!,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Home1Page()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Select your Board'),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _boards.map((board) {
                final bool isSelected = _selectedBoard == board;
                return _BoardCard(
                  label: board,
                  isSelected: isSelected,
                  purpleDark: purpleDark,
                  purpleMid: purpleMid,
                  onTap: () => setState(() => _selectedBoard = board),
                );
              }).toList(),
            ),

            const SizedBox(height: 36),
            _SectionTitle(title: 'Select your Class'),
            const SizedBox(height: 18),

            _ClassDropdown(
              selectedClass: _selectedClass,
              classes: _classes,
              purpleDark: purpleDark,
              purpleMid: purpleMid,
              onChanged: (val) => setState(() => _selectedClass = val),
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_selectedBoard != null && _selectedClass != null)
                    ? _onContinue
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purpleDark,
                  disabledBackgroundColor: purpleDark.withOpacity(0.35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── sub-widgets (identical to your originals) ──────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E), letterSpacing: -0.3,
            )),
        const SizedBox(height: 6),
        Container(
          width: 60, height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF5B1F7A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _BoardCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color purpleDark, purpleMid;
  final VoidCallback onTap;
  const _BoardCard({
    required this.label, required this.isSelected,
    required this.purpleDark, required this.purpleMid,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final double cardSize = (MediaQuery.of(context).size.width - 48 - 24) / 4;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cardSize, height: cardSize + 10,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [purpleDark, purpleMid]
                : [const Color(0xFFCF9FE0), const Color(0xFFB06FCC)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? purpleDark : Colors.black)
                  .withOpacity(isSelected ? 0.35 : 0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(height: 4),
            ],
            Text(label,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: 0.3,
                )),
          ],
        ),
      ),
    );
  }
}

class _ClassDropdown extends StatelessWidget {
  final String? selectedClass;
  final List<String> classes;
  final Color purpleDark, purpleMid;
  final ValueChanged<String?> onChanged;
  const _ClassDropdown({
    required this.selectedClass, required this.classes,
    required this.purpleDark, required this.purpleMid,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFCF9FE0), Color(0xFFB06FCC)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08),
              blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedClass,
          isExpanded: true,
          dropdownColor: const Color(0xFFEDD6F7),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white, size: 26),
          hint: const Text('What is your class?',
              style: TextStyle(color: Colors.white,
                  fontSize: 14, fontWeight: FontWeight.w500)),
          style: const TextStyle(color: Color(0xFF1A1A2E),
              fontSize: 14, fontWeight: FontWeight.w600),
          selectedItemBuilder: (context) => classes
              .map((c) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(c,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ))
              .toList(),
          items: classes
              .map((cls) => DropdownMenuItem<String>(
                  value: cls, child: Text(cls)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}