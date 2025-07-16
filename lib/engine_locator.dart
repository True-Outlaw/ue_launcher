import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as pathPckg;

import 'models/UnrealEngineInfo.dart';

class EngineLocator {
  Future<List<UnrealEngineInfo?>> getEngineInfoFromPath(String enginePath) async {
    final engineDir = Directory(enginePath);
    final results = <UnrealEngineInfo>[];

    if (!await engineDir.exists()) {
      if (kDebugMode) {
        print('Engine directory does not exist: $enginePath');
      }
      return results;
    }

    // Check the root directory itself
    final rootInfo = await _tryParseEngineInfo(engineDir);
    if (rootInfo != null) {
      results.add(rootInfo);
    }

    // Check immediate subdirectories
    await for (final entity in engineDir.list(followLinks: false)) {
      if (entity is Directory) {
        final info = await _tryParseEngineInfo(entity);
        if (info != null) {
          results.add(info);
        }
      }
    }

    if (results.isEmpty && kDebugMode) {
      print('No Unreal Engine installations found in $enginePath or its immediate subdirectories.');
    }

    return results;
  }

  Future<List<UnrealEngineInfo?>> checkDefaultEngineLocation() async {
    final List<UnrealEngineInfo> results = [];

    if (Platform.isWindows) {
      const List<String> defaultWindowsPaths = [
        'C:\\Program Files\\Epic Games',
      ];

      for (String basePath in defaultWindowsPaths) {
        final baseDir = Directory(basePath);
        if (await baseDir.exists()) {
          await for (final entity in baseDir.list()) {
            if (entity is Directory) {
              if (entity.path.contains('UE_') || entity.path.contains('UnrealEngine')) {
                final engineInfos = await getEngineInfoFromPath(entity.path);
                results.addAll(engineInfos.whereType<UnrealEngineInfo>());
              }
            }
          }
        }
      }
    }
    return results;
  }

  Future<String?> pickEngineDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Please select your Unreal Engine installation directory',
    );
    return selectedDirectory;
  }

  Future<UnrealEngineInfo?> _tryParseEngineInfo(Directory dir) async {
    final buildVersionFile = File(pathPckg.join(dir.path, 'Engine', 'Build', 'Build.version'));

    if (await buildVersionFile.exists()) {
      try {
        final content = await buildVersionFile.readAsString();
        final jsonData = jsonDecode(content);
        final major = jsonData['MajorVersion'];
        final minor = jsonData['MinorVersion'];
        final patch = jsonData['PatchVersion'];
        final branch = jsonData['BranchName'];

        String versionString = '$major.$minor.$patch';

        return UnrealEngineInfo(
          version: versionString,
          path: dir.path,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing Build.version in ${dir.path}: $e');
        }
        return null;
      }
    }
    return null;
  }

  // TODO: Add methods to save/load engine paths from SharedPreferences so user selections persist across app launches.
}
