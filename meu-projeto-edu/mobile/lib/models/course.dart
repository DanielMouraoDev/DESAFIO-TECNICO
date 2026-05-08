class Course {
  final int? id;
  final int? remoteId;
  final String title;
  final String description;
  final bool active;
  final bool pendingSync;

  Course({
    this.id,
    this.remoteId,
    required this.title,
    required this.description,
    this.active = true,
    this.pendingSync = false,
  });

  Course copyWith({
    int? id,
    int? remoteId,
    String? title,
    String? description,
    bool? active,
    bool? pendingSync,
  }) {
    return Course(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      title: title ?? this.title,
      description: description ?? this.description,
      active: active ?? this.active,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  factory Course.fromMap(Map<String, Object?> map) {
    return Course(
      id: map['id'] as int?,
      remoteId: map['remote_id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      active: (map['active'] as int) == 1,
      pendingSync: (map['pending_sync'] as int) == 1,
    );
  }

  factory Course.fromApi(Map<String, dynamic> json) {
    return Course(
      remoteId: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      active: json['active'] as bool? ?? true,
      pendingSync: false,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'remote_id': remoteId,
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
