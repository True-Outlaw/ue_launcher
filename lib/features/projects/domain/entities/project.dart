class Project {
  final String path;
  final String name;
  final String engineVersion;
  final DateTime created;
  final DateTime modified;
  final String? thumbnailPath;
  final List<String> tags;

  Project({
    required this.path,
    required this.name,
    required this.engineVersion,
    required this.created,
    required this.modified,
    this.thumbnailPath,
    this.tags = const [],
  });

  Project copyWith({
    String? path,
    String? name,
    String? engineVersion,
    DateTime? created,
    DateTime? modified,
    String? thumbnailPath,
    List<String>? tags,
  }) {
    return Project(
      path: path ?? this.path,
      name: name ?? this.name,
      engineVersion: engineVersion ?? this.engineVersion,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Project && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}
