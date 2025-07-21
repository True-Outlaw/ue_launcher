import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_pckg;

class UnrealProjectData {
  final String path;
  final String name;
  final String engineVersion;
  final DateTime created;
  final DateTime modified;
  final String? thumbnailPath;

  UnrealProjectData({
    required this.path,
    required this.name,
    required this.engineVersion,
    required this.created,
    required this.modified,
    this.thumbnailPath,
  });

  static Future<UnrealProjectData?> fromFile(File file) async {
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

      return UnrealProjectData(
        path: file.path,
        name: name,
        engineVersion: version,
        created: stat.changed,
        modified: stat.modified,
        thumbnailPath: thumbnail.isNotEmpty ? thumbnail : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to parse: ${file.path}');
      }
      return null;
    }
  }
}
