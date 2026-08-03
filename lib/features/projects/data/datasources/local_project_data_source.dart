import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_pckg;
import 'package:path_provider/path_provider.dart';
import '../models/project_model.dart';

abstract class ProjectDataSource {
  Future<List<ProjectModel>> scanForUProjects(String folder);
  Future<void> saveProjects(Map<String, dynamic> data);
  Future<Map<String, dynamic>> loadProjects();
}

class LocalProjectDataSource implements ProjectDataSource {
  static const _fileName = 'projects.json';

  Future<File> get _localFile async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
  Future<Map<String, dynamic>> loadProjects() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents);
      }
    } catch (e) {
      if (kDebugMode) print('Failed to load projects: $e');
    }
    return {};
  }

  @override
  Future<void> saveProjects(Map<String, dynamic> data) async {
    try {
      final file = await _localFile;
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      if (kDebugMode) print('Failed to save projects: $e');
    }
  }

  @override
  Future<List<ProjectModel>> scanForUProjects(String folder) async {
    final projects = <ProjectModel>[];
    final Set<String> visitedFolders = {};

    Future<void> scanDirectory(Directory directory) async {
      if (visitedFolders.contains(directory.path)) return;
      visitedFolders.add(directory.path);

      try {
        final List<FileSystemEntity> entities = await directory.list().toList();
        bool uprojectFoundInCurrentDir = false;

        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.uproject')) {
            final proj = await _parseProjectFile(entity);
            if (proj != null) {
              projects.add(proj);
              uprojectFoundInCurrentDir = true;
            }
          }
        }

        if (uprojectFoundInCurrentDir) return;

        for (final entity in entities) {
          if (entity is Directory) {
            await scanDirectory(entity);
          }
        }
      } catch (e) {
        if (kDebugMode) print('Error scanning directory ${directory.path}: $e');
      }
    }

    await scanDirectory(Directory(folder));
    return projects;
  }

  Future<ProjectModel?> _parseProjectFile(File file) async {
    try {
      final jsonText = await file.readAsString();
      final data = json.decode(jsonText);

      final name = data['Modules']?[0]?['Name'] ?? path_pckg.basenameWithoutExtension(file.path);
      final version = data['EngineAssociation'] ?? 'Unknown';

      final stat = await file.stat();

      final dir = file.parent;
      final thumbPaths = [
        dir.uri.resolve('Saved/AutoScreenshot.png').toFilePath(),
        dir.uri.resolve('$name.png').toFilePath(),
        dir.uri.resolve('Content/Icons/ProjectIcon.png').toFilePath(),
      ];

      final thumbnail = thumbPaths.firstWhere(
        (p) => File(p).existsSync(),
        orElse: () => '',
      );

      return ProjectModel(
        path: file.path,
        name: name,
        engineVersion: version,
        created: stat.changed,
        modified: stat.modified,
        thumbnailPath: thumbnail.isNotEmpty ? thumbnail : null,
        tags: [],
      );
    } catch (e) {
      if (kDebugMode) print('Failed to parse: ${file.path}');
      return null;
    }
  }
}
