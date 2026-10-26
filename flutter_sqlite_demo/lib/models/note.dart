class Note {
  final int? id;
  final String title;
  final String content;
  final String createdAt;
  final int color;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.color = 0xFFFFFFFF,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt,
      'color': color,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: map['created_at'] ?? '',
      color: map['color'] ?? 0xFFFFFFFF,
    );
  }
}