class Course {
  final int? id;
  final String title;
  final String description;
  final bool active;
  final bool pendingSync;

  Course({
    this.id,
    required this.title,
    required this.description,
    this.active = true,
    this.pendingSync = false,
  });

  Course copyWith({
    int? id,
    String? title,
    String? description,
    bool? active,
    bool? pendingSync,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      active: active ?? this.active,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  factory Course.fromMap(Map<String, Object?> map) {
    return Course(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      active: (map['active'] as int) == 1,
      pendingSync: (map['pending_sync'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'active': active ? 1 : 0,
      'pending_sync': pendingSync ? 1 : 0,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'title': title,
      'description': description,
      'active': active,
    };
  }
}
