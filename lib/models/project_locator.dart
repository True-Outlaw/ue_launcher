import 'dart:io';
import 'package:flutter/foundation.dart';
import 'unreal_project_data.dart';

class ProjectLocator {
  Future<List<UnrealProjectData>> scanForUProjects(String folder) async {
    final projects = <UnrealProjectData>[];
    final Set<String> visitedFolders = {};

    Future<void> scanDirectory(Directory directory) async {
      if (visitedFolders.contains(directory.path)) {
        return;
      }
      visitedFolders.add(directory.path);

      try {
        final List<FileSystemEntity> entities = await directory.list().toList();
        bool uprojectFoundInCurrentDir = false;

        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.uproject')) {
            final proj = await UnrealProjectData.fromFile(entity);
            if (proj != null) {
              projects.add(proj);
              uprojectFoundInCurrentDir = true;
            }
          }
        }

        if (uprojectFoundInCurrentDir) {
          return;
        }

        for (final entity in entities) {
          if (entity is Directory) {
            await scanDirectory(entity);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error scanning directory ${directory.path}: $e');
        }
      }
    }

    await scanDirectory(Directory(folder));
    return projects;
  }
}
