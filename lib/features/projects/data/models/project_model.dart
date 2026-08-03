import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  ProjectModel({
    required super.path,
    required super.name,
    required super.engineVersion,
    required super.created,
    required super.modified,
    super.thumbnailPath,
    super.tags,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      name: json['name'],
      path: json['path'],
      created: DateTime.parse(json['created']),
      modified: DateTime.parse(json['modified']),
      engineVersion: json['engineVersion'],
      thumbnailPath: json['thumbnailPath'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'created': created.toIso8601String(),
    'modified': modified.toIso8601String(),
    'engineVersion': engineVersion,
    'thumbnailPath': thumbnailPath,
    'tags': tags,
  };

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      path: project.path,
      name: project.name,
      engineVersion: project.engineVersion,
      created: project.created,
      modified: project.modified,
      thumbnailPath: project.thumbnailPath,
      tags: project.tags,
    );
  }
}
