import 'dart:io';
import 'package:flutter/foundation.dart';
import '../entities/project.dart';

class GenerateProjectFilesUseCase {
  Future<bool> call(Project project, {String? enginePath}) async {
    final uprojectPath = project.path;

    if (Platform.isWindows) {
      // 1. Try engine-specific Build.bat if enginePath is provided
      if (enginePath != null && enginePath.isNotEmpty) {
        final buildBat = File('$enginePath\\Engine\\Build\\BatchFiles\\Build.bat');
        if (await buildBat.exists()) {
          try {
            final result = await Process.run(
              buildBat.path,
              ['-projectfiles', '-project=$uprojectPath', '-game', '-rocket', '-progress'],
              runInShell: true,
            );
            if (result.exitCode == 0) return true;
          } catch (e) {
            if (kDebugMode) print('Build.bat failed: $e');
          }
        }
      }

      // 2. Try default UnrealVersionSelector paths
      const uvsPaths = [
        r'C:\Program Files (x86)\Epic Games\Launcher\Engine\Binaries\Win64\UnrealVersionSelector.exe',
        r'C:\Program Files\Epic Games\Launcher\Engine\Binaries\Win64\UnrealVersionSelector.exe',
      ];

      for (final uvs in uvsPaths) {
        if (await File(uvs).exists()) {
          try {
            final result = await Process.run(uvs, ['/projectfiles', uprojectPath]);
            if (result.exitCode == 0) return true;
          } catch (e) {
            if (kDebugMode) print('UnrealVersionSelector failed: $e');
          }
        }
      }

      // 3. Try running UnrealVersionSelector directly from PATH
      try {
        final result = await Process.run('UnrealVersionSelector', ['/projectfiles', uprojectPath], runInShell: true);
        if (result.exitCode == 0) return true;
      } catch (_) {}
    }

    return false;
  }
}
