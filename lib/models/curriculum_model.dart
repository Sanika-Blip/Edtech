// models/curriculum_model.dart
// Pure Dart — no external dependencies. Fully offline.

// ─────────────────────────────────────────────────────────────────────────────
// CHAPTER
// ─────────────────────────────────────────────────────────────────────────────
class Chapter {
  final String id;
  final String title;
  final String description;
  final List<String> topics;       // bullet points shown in chapter detail
  final String? videoUrl;          // local asset path or future network URL
  final String? notesAssetPath;    // PDF / text asset path (optional)
  final bool isCompleted;

  const Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.topics,
    this.videoUrl,
    this.notesAssetPath,
    this.isCompleted = false,
  });

  Chapter copyWith({bool? isCompleted}) => Chapter(
        id: id,
        title: title,
        description: description,
        topics: topics,
        videoUrl: videoUrl,
        notesAssetPath: notesAssetPath,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBJECT
// ─────────────────────────────────────────────────────────────────────────────
class Subject {
  final String id;
  final String name;
  final String emoji;
  final List<Chapter> chapters;

  const Subject({
    required this.id,
    required this.name,
    required this.emoji,
    required this.chapters,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// USER SESSION  (stored in Hive — integrates with your existing login box)
// ─────────────────────────────────────────────────────────────────────────────
class UserSession {
  final String username;
  final String board;       // e.g. 'CBSE'
  final String className;   // e.g. 'Class 10'

  const UserSession({
    required this.username,
    required this.board,
    required this.className,
  });

  // ── Hive serialization (uses your existing raw box — no TypeAdapter needed)
  Map<String, dynamic> toMap() => {
        'username': username,
        'board': board,
        'className': className,
      };

  factory UserSession.fromMap(Map<dynamic, dynamic> map) => UserSession(
        username: map['username'] as String,
        board: map['board'] as String,
        className: map['className'] as String,
      );
}