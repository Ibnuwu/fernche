class NoteModel {
  final int? id;
  final String title;
  final String? content;
  final String tag; // General, Idea, Project, Code Snippet, Organization
  final int expectedPayout;
  final String status; // OPEN, PROGRESS, DONE, ARCHIVED
  final String createdAt;
  final String updatedAt;

  const NoteModel({
    this.id,
    required this.title,
    this.content,
    required this.tag,
    this.expectedPayout = 0,
    this.status = 'OPEN',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'tag': tag,
      'expected_payout': expectedPayout,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String?,
      tag: map['tag'] as String,
      expectedPayout: (map['expected_payout'] as int?) ?? 0,
      status: (map['status'] as String?) ?? 'OPEN',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  NoteModel copyWith({
    int? id,
    String? title,
    String? content,
    String? tag,
    int? expectedPayout,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      expectedPayout: expectedPayout ?? this.expectedPayout,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isProject => tag == 'Project';
  bool get isDone => status == 'DONE';
  bool get isCodeSnippet => tag == 'Code Snippet';
  bool get hasPayout => isProject && expectedPayout > 0;
}
