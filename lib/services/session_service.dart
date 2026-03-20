// lib/services/session_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/curriculum_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WATCH HISTORY ENTRY
// ─────────────────────────────────────────────────────────────────────────────
class WatchHistoryEntry {
  final String subject;
  final String chapterTitle;
  final String topicTitle;
  final int    watchedSeconds;
  final String dateStr; // 'yyyy-MM-dd'

  const WatchHistoryEntry({
    required this.subject,
    required this.chapterTitle,
    required this.topicTitle,
    required this.watchedSeconds,
    required this.dateStr,
  });

  String get durationLabel {
    final m = watchedSeconds ~/ 60;
    final s = watchedSeconds % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}m';
    return '${m}m ${s}s';
  }

  bool get isToday => dateStr == SessionService.todayString();
}

// ─────────────────────────────────────────────────────────────────────────────
// SESSION SERVICE
// ─────────────────────────────────────────────────────────────────────────────
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  // Box names
  static const _sessionBoxName  = 'sessionBox';
  static const _progressBoxName = 'progressBox';

  // Session keys
  static const _kUsername     = 'username';
  static const _kBoard        = 'board';
  static const _kClass        = 'className';

  // Streak keys
  static const _kStreakCount   = 'streakCount';
  static const _kLastWatchDay  = 'lastWatchDay';

  // History key — stored as records separated by §
  // Each record: subject¦chapterTitle¦topicTitle¦watchedSeconds¦yyyy-MM-dd
  static const _kHistory       = 'watchHistory';
  static const _recSep         = '§';
  static const _fldSep         = '¦';
  static const _maxHistory     = 100;

  // ── Init ────────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_sessionBoxName);
    await Hive.openBox<bool>(_progressBoxName);
  }

  Box       get _sBox => Hive.box(_sessionBoxName);
  Box<bool> get _pBox => Hive.box<bool>(_progressBoxName);

  // ── Date helpers ─────────────────────────────────────────────────────────────
  static String todayString() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  static String _yesterday() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  }

  // ── Session ──────────────────────────────────────────────────────────────────
  Future<void> saveSelection({
    required String username,
    required String board,
    required String className,
  }) async {
    await _sBox.put(_kUsername, username);
    await _sBox.put(_kBoard,    board);
    await _sBox.put(_kClass,    className);
  }

  UserSession? getSession() {
    final u = _sBox.get(_kUsername) as String?;
    final b = _sBox.get(_kBoard)    as String?;
    final c = _sBox.get(_kClass)    as String?;
    if (u == null || b == null || c == null) return null;
    return UserSession(username: u, board: b, className: c);
  }

  bool get hasSession => getSession() != null;

  Future<void> clearSession() async {
    await _sBox.clear();
    await Hive.box('userBox').put('isLoggedIn', false);
  }

  // ── Streak ───────────────────────────────────────────────────────────────────
  /// Call when 2-min video threshold fires. Returns new streak count.
  Future<int> recordWatchToday() async {
    final today = todayString();
    final last  = _sBox.get(_kLastWatchDay) as String?;

    // Already recorded today
    if (last == today) return currentStreak;

    int newStreak;
    if (last == null) {
      newStreak = 1;
    } else if (last == _yesterday()) {
      newStreak = currentStreak + 1;
    } else {
      newStreak = 1; // gap → reset
    }

    await _sBox.put(_kStreakCount,  newStreak);
    await _sBox.put(_kLastWatchDay, today);
    return newStreak;
  }

  /// Current streak. Auto-resets if user missed yesterday.
  int get currentStreak {
    final count = _sBox.get(_kStreakCount,  defaultValue: 0) as int;
    final last  = _sBox.get(_kLastWatchDay) as String?;
    if (count == 0 || last == null) return 0;

    final today = todayString();
    final yest  = _yesterday();
    if (last != today && last != yest) {
      // streak broken — reset silently
      _sBox.put(_kStreakCount,  0);
      _sBox.put(_kLastWatchDay, null);
      return 0;
    }
    return count;
  }

  bool get watchedToday =>
      (_sBox.get(_kLastWatchDay) as String?) == todayString();

  // ── Watch History ─────────────────────────────────────────────────────────────
  /// Call when 2-min threshold fires.
  Future<void> recordWatchHistory({
    required String subject,
    required String chapterTitle,
    required String topicTitle,
    required int    watchedSeconds,
  }) async {
    final today   = todayString();
    final newEntry = [
      subject, chapterTitle, topicTitle,
      watchedSeconds.toString(), today,
    ].join(_fldSep);

    final existing = _sBox.get(_kHistory, defaultValue: '') as String;
    final records  = existing.isEmpty
        ? <String>[]
        : existing.split(_recSep).where((s) => s.isNotEmpty).toList();

    // Remove duplicate for same topic today
    records.removeWhere((r) {
      final p = r.split(_fldSep);
      return p.length >= 5 &&
          p[0] == subject &&
          p[1] == chapterTitle &&
          p[2] == topicTitle &&
          p[4] == today;
    });

    records.insert(0, newEntry); // newest first

    if (records.length > _maxHistory) {
      records.removeRange(_maxHistory, records.length);
    }

    await _sBox.put(_kHistory, records.join(_recSep));
  }

  /// All history, newest first.
  List<WatchHistoryEntry> getWatchHistory() {
    final raw = _sBox.get(_kHistory, defaultValue: '') as String;
    if (raw.isEmpty) return [];
    return raw
        .split(_recSep)
        .where((s) => s.isNotEmpty)
        .map((s) {
          final p = s.split(_fldSep);
          if (p.length < 5) return null;
          return WatchHistoryEntry(
            subject:        p[0],
            chapterTitle:   p[1],
            topicTitle:     p[2],
            watchedSeconds: int.tryParse(p[3]) ?? 0,
            dateStr:        p[4],
          );
        })
        .whereType<WatchHistoryEntry>()
        .toList();
  }

  Future<void> clearWatchHistory() async => _sBox.delete(_kHistory);

  // ── Topic Progress ────────────────────────────────────────────────────────────
  // Key: board|className|subjectName|chapterId|topic_N

  String _topicKey({
    required String board,
    required String className,
    required String subjectName,
    required String chapterId,
    required int    topicIndex,
  }) => '$board|$className|$subjectName|$chapterId|topic_$topicIndex';

  Future<void> markTopicComplete({
    required String board,
    required String className,
    required String subjectName,
    required String chapterId,
    required int    topicIndex,
  }) async {
    await _pBox.put(
      _topicKey(board: board, className: className,
        subjectName: subjectName, chapterId: chapterId,
        topicIndex: topicIndex),
      true,
    );
  }

  bool isTopicComplete({
    required String board,
    required String className,
    required String subjectName,
    required String chapterId,
    required int    topicIndex,
  }) {
    return _pBox.get(
      _topicKey(board: board, className: className,
        subjectName: subjectName, chapterId: chapterId,
        topicIndex: topicIndex),
      defaultValue: false,
    ) ?? false;
  }

  int completedTopicsInChapter({
    required String board,
    required String className,
    required String subjectName,
    required String chapterId,
  }) {
    final prefix = '$board|$className|$subjectName|$chapterId|topic_';
    return _pBox.keys
        .where((k) => (k as String).startsWith(prefix))
        .where((k) => _pBox.get(k) == true)
        .length;
  }

  Future<void> clearProgress() async => _pBox.clear();
}