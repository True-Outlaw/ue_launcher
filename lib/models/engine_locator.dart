import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_pckg;

import 'unreal_engine_info.dart';

class EngineLocator {
  Future<List<UnrealEngineInfo>> getEngineInfoFromPath(String enginePath) async {
    return _findEnginesInDirectory(Directory(enginePath), includeRoot: true);
  }

  Future<List<UnrealEngineInfo>> checkDefaultEngineLocation() async {
    final List<UnrealEngineInfo> results = [];

    if (Platform.isWindows) {
      const defaultWindowsPaths = ['C:\\Program Files\\Epic Games'];

      for (final path in defaultWindowsPaths) {
        final dir = Directory(path);
        final foundEngines = await _findEnginesInDirectory(dir, includeRoot: false);
        results.addAll(foundEngines);
      }
    }

    return results;
  }

  Future<List<UnrealEngineInfo>> _findEnginesInDirectory(Directory dir, {bool includeRoot = false}) async {
    final List<UnrealEngineInfo> results = [];

    if (!await dir.exists()) {
      if (kDebugMode) {
        print('Directory does not exist: ${dir.path}');
      }
      return results;
    }

    if (includeRoot) {
      final rootInfo = await _tryParseEngineInfo(dir);
      if (rootInfo != null) {
        results.add(rootInfo);
      }
    }

    await for (final entity in dir.list(followLinks: false)) {
      if (entity is Directory) {
        final dirName = entity.path.toLowerCase();
        if (dirName.contains('ue_') || dirName.contains('unrealengine')) {
          final info = await _tryParseEngineInfo(entity);
          if (info != null) {
            results.add(info);
          }
        }
      }
    }

    if (results.isEmpty) {
      if (kDebugMode) {
        print('No Unreal Engine installations found in ${dir.path}${includeRoot ? " or its subdirectories" : ""}.');
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
    final buildVersionFile = File(path_pckg.join(dir.path, 'Engine', 'Build', 'Build.version'));

    if (await buildVersionFile.exists()) {
      try {
        final content = await buildVersionFile.readAsString();
        final jsonData = jsonDecode(content);
        final major = jsonData['MajorVersion'];
        final minor = jsonData['MinorVersion'];
        final patch = jsonData['PatchVersion'];

        String versionString = '$major.$minor.$patch';

        String executablePath = path_pckg.join(dir.path, 'Engine', 'Binaries', 'Win64', 'UnrealEditor.exe');

        final executableFile = File(executablePath);

        if (!await executableFile.exists()) {
          if (kDebugMode) {
            print('Executable file does not exist: $executablePath');
          }
          // TODO: You might want to return null here or handle this case differently,
          // as an engine without an executable isn't launchable.
          // For now, we'll still return the info but the executablePath will be invalid.
        }

        return UnrealEngineInfo(
          version: versionString,
          path: dir.path,
          executablePath: executablePath,
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
