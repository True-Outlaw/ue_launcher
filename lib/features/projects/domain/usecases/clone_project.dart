import 'dart:io';
import 'package:path/path.dart' as path_pckg;
import '../entities/project.dart';

class CloneProjectUseCase {
  Future<void> call(
    Project source,
    String newName,
    String targetParentPath, {
    void Function(String message, double progress)? onProgress,
  }) async {
    final sourceProjectFile = File(source.path);
    final sourceDir = sourceProjectFile.parent;
    final targetDir = Directory(path_pckg.join(targetParentPath, newName));

    if (await targetDir.exists()) {
      throw Exception('A folder with the name "$newName" already exists.');
    }

    onProgress?.call('Creating directory...', 0.1);
    await targetDir.create(recursive: true);

    final essentialFolders = ['Config', 'Content', 'Source'];
    double progress = 0.2;
    final stepSize = 0.6 / essentialFolders.length;

    for (final folderName in essentialFolders) {
      final sourceFolder = Directory(path_pckg.join(sourceDir.path, folderName));
      if (await sourceFolder.exists()) {
        onProgress?.call('Copying $folderName...', progress);
        final targetFolder = Directory(path_pckg.join(targetDir.path, folderName));
        await _copyDirectory(sourceFolder, targetFolder);
      }
      progress += stepSize;
    }

    onProgress?.call('Finalizing .uproject file...', 0.9);
    final targetProjectFile = File(path_pckg.join(targetDir.path, '$newName.uproject'));
    await sourceProjectFile.copy(targetProjectFile.path);

    if (source.thumbnailPath != null) {
      final thumbFile = File(source.thumbnailPath!);
      if (path_pckg.isWithin(sourceDir.path, thumbFile.path) &&
          !path_pckg.split(path_pckg.relative(thumbFile.path, from: sourceDir.path)).contains('Saved')) {
        onProgress?.call('Copying thumbnail...', 0.95);
        final relativeThumbPath = path_pckg.relative(thumbFile.path, from: sourceDir.path);
        final targetThumbPath = path_pckg.join(targetDir.path, relativeThumbPath);

        final targetThumbDir = Directory(path_pckg.dirname(targetThumbPath));
        if (!await targetThumbDir.exists()) {
          await targetThumbDir.create(recursive: true);
        }
        await thumbFile.copy(targetThumbPath);
      }
    }
    onProgress?.call('Done', 1.0);
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDirectory = Directory(path_pckg.join(destination.absolute.path, path_pckg.basename(entity.path)));
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        await entity.copy(path_pckg.join(destination.path, path_pckg.basename(entity.path)));
      }
    }
  }
}
