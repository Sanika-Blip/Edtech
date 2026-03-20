// services/session_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/curriculum_model.dart';

class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  static const String _sessionBoxName  = 'sessionBox';
  static const String _progressBoxName = 'progressBox';

  static const String _kBoard    = 'board';
  static const String _kClass    = 'className';
  static const String _kUsername = 'username';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_sessionBoxName);
    await Hive.openBox<bool>(_progressBoxName);
  }

  Box       get _sessionBox  => Hive.box(_sessionBoxName);
  Box<bool> get _progressBox => Hive.box<bool>(_progressBoxName);

  // ── Session ─────────────────────────────────────────────────────────────────
  Future<void> saveSelection({
    required String username,
    required String board,
    required String className,
  }) async {
    await _sessionBox.put(_kUsername, username);
    await _sessionBox.put(_kBoard,    board);
    await _sessionBox.put(_kClass,    className);
  }

  UserSession? getSession() {
    final username  = _sessionBox.get(_kUsername) as String?;
    final board     = _sessionBox.get(_kBoard)    as String?;
    final className = _sessionBox.get(_kClass)    as String?;
    if (username == null || board == null || className == null) return null;
    return UserSession(username: username, board: board, className: className);
  }

  bool get hasSession => getSession() != null;

  Future<void> clearSession() async {
    await _sessionBox.clear();
    final userBox = Hive.box('userBox');
    await userBox.put('isLoggedIn', false);
  }

  // ── Progress ────────────────────────────────────────────────────────────────
  // KEY FORMAT: 'board|className|subjectName|chapterId|topicIndex'
  // The full path ensures no collision across boards, classes, subjects or chapters.

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
    await _progressBox.put(
      _topicKey(
        board: board, className: className,
        subjectName: subjectName, chapterId: chapterId,
        topicIndex: topicIndex,
      ),
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
    return _progressBox.get(
      _topicKey(
        board: board, className: className,
        subjectName: subjectName, chapterId: chapterId,
        topicIndex: topicIndex,
      ),
      defaultValue: false,
    ) ?? false;
  }

  /// How many topics are done in a specific chapter
  int completedTopicsInChapter({
    required String board,
    required String className,
    required String subjectName,
    required String chapterId,
  }) {
    final prefix = '$board|$className|$subjectName|$chapterId|topic_';
    return _progressBox.keys
        .where((k) => (k as String).startsWith(prefix))
        .where((k) => _progressBox.get(k) == true)
        .length;
  }

  Future<void> clearProgress() async => _progressBox.clear();
}