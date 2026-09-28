import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../entities/project.dart';

class CleanResult {
  final int bytesFreed;
  final List<String> deletedFolders;

  CleanResult({required this.bytesFreed, required this.deletedFolders});
}

class CleanProjectCacheUseCase {
  static const List<String> cacheFolderNames = [
    'Intermediate',
    'Saved',
    'DerivedDataCache',
    'Binaries',
    '.vs',
    '.idea',
  ];

  Future<int> estimateCacheSize(Project project) async {
    final projectDir = File(project.path).parent;
    int totalBytes = 0;

    for (final folderName in cacheFolderNames) {
      final dir = Directory(p.join(projectDir.path, folderName));
      if (await dir.exists()) {
        try {
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              try {
                totalBytes += await entity.length();
              } catch (_) {}
            }
          }
        } catch (_) {}
      }
    }
    return totalBytes;
  }

  Future<CleanResult> call(Project project) async {
    final projectDir = File(project.path).parent;
    int totalFreed = 0;
    final List<String> deleted = [];

    for (final folderName in cacheFolderNames) {
      final dir = Directory(p.join(projectDir.path, folderName));
      if (await dir.exists()) {
        try {
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              try {
                totalFreed += await entity.length();
              } catch (_) {}
            }
          }
          await dir.delete(recursive: true);
          deleted.add(folderName);
        } catch (e) {
          if (kDebugMode) print('Failed to delete $folderName: $e');
        }
      }
    }

    return CleanResult(bytesFreed: totalFreed, deletedFolders: deleted);
  }
}
