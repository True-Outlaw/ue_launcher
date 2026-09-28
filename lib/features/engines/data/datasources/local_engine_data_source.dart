import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path_pckg;
import 'package:path_provider/path_provider.dart';
import 'package:win32_registry/win32_registry.dart';
import '../../domain/entities/engine.dart';
import '../models/engine_model.dart';

abstract class EngineDataSource {
  Future<List<EngineModel>> scanForEngines(String folder, {bool includeRoot = false});
  Future<List<EngineModel>> getWindowsDefaultEngines();
  Future<List<EngineModel>> loadSavedEngines();
  Future<void> saveEngines(List<EngineModel> engines);
  Future<String?> fetchLatestVersion();
}

class LocalEngineDataSource implements EngineDataSource {
  static const _fileName = 'engines.json';
  static const String _releaseNotesUrl = 'https://www.unrealengine.com/en-US/release-notes';

  Future<File> get _localFile async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
  Future<List<EngineModel>> loadSavedEngines() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        return jsonList.map((j) => EngineModel.fromJson(j)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Failed to load engines: $e');
    }
    return [];
  }

  @override
  Future<void> saveEngines(List<EngineModel> engines) async {
    try {
      final file = await _localFile;
      final jsonList = engines.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      if (kDebugMode) print('Failed to save engines: $e');
    }
  }

  @override
  Future<List<EngineModel>> getWindowsDefaultEngines() async {
    final List<EngineModel> results = [];
    if (Platform.isWindows) {
      final potentialPaths = await _getWindowsEnginePaths();
      final Set<String> seenPaths = {};

      for (final path in potentialPaths) {
        final dir = Directory(path);
        if (!await dir.exists()) continue;

        // 1. Try directly parsing this directory as an engine root
        final directEngine = await _tryParseEngineInfo(dir);
        if (directEngine != null) {
          if (!seenPaths.contains(directEngine.path.toLowerCase())) {
            results.add(directEngine);
            seenPaths.add(directEngine.path.toLowerCase());
          }
        } else {
          // 2. Scan immediate subdirectories
          final subEngines = await scanForEngines(path, includeRoot: false);
          for (final engine in subEngines) {
            if (!seenPaths.contains(engine.path.toLowerCase())) {
              results.add(engine);
              seenPaths.add(engine.path.toLowerCase());
            }
          }
        }
      }
    }
    return results;
  }

  Future<List<String>> _getWindowsEnginePaths() async {
    if (!Platform.isWindows) return [];
    final Set<String> paths = {};

    // 1. Epic Games Launcher Manifests (.item files)
    try {
      final programData = Platform.environment['PROGRAMDATA'] ?? r'C:\ProgramData';
      final manifestsDir = Directory(path_pckg.join(programData, 'Epic', 'EpicGamesLauncher', 'Data', 'Manifests'));
      if (await manifestsDir.exists()) {
        await for (final entity in manifestsDir.list()) {
          if (entity is File && entity.path.endsWith('.item')) {
            try {
              final content = await entity.readAsString();
              final json = jsonDecode(content);
              final appName = json['AppName'] as String? ?? '';
              final installLocation = json['InstallLocation'] as String? ?? '';
              if (appName.startsWith('UE_') && installLocation.isNotEmpty) {
                paths.add(installLocation);
              }
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error reading Epic manifests: $e');
    }

    // 2. Windows Registry - HKLM\SOFTWARE\EpicGames\Unreal Engine
    try {
      const regPath = r'SOFTWARE\EpicGames\Unreal Engine';
      final key = Registry.openPath(RegistryHive.localMachine, path: regPath);
      for (final subkeyName in key.subkeyNames) {
        try {
          final subkey = Registry.openPath(RegistryHive.localMachine, path: '$regPath\\$subkeyName');
          final installDir = subkey.getStringValue('InstalledDirectory');
          if (installDir != null && installDir.isNotEmpty) {
            paths.add(installDir);
          }
          subkey.close();
        } catch (_) {}
      }
      key.close();
    } catch (_) {}

    // 3. Windows Registry - HKCU\Software\Epic Games\Unreal Engine\Builds (Custom source builds)
    try {
      const buildsPath = r'Software\Epic Games\Unreal Engine\Builds';
      final buildsKey = Registry.openPath(RegistryHive.currentUser, path: buildsPath);
      for (final val in buildsKey.values) {
        try {
          final installDir = buildsKey.getStringValue(val.name);
          if (installDir != null && installDir.isNotEmpty) {
            paths.add(installDir);
          }
        } catch (_) {}
      }
      buildsKey.close();
    } catch (_) {}

    // 4. Default Epic Games installation directory
    paths.add(r'C:\Program Files\Epic Games');

    return paths.toList();
  }

  @override
  Future<List<EngineModel>> scanForEngines(String folder, {bool includeRoot = false}) async {
    final List<EngineModel> results = [];
    final dir = Directory(folder);
    if (!await dir.exists()) return results;

    if (includeRoot) {
      final rootInfo = await _tryParseEngineInfo(dir);
      if (rootInfo != null) results.add(rootInfo);
    }

    await for (final entity in dir.list(followLinks: false)) {
      if (entity is Directory) {
        final dirName = entity.path.toLowerCase();
        if (dirName.contains('ue_') || dirName.contains('unrealengine')) {
          final info = await _tryParseEngineInfo(entity);
          if (info != null) results.add(info);
        }
      }
    }
    return results;
  }

  @override
  Future<String?> fetchLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(_releaseNotesUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final regExp = RegExp(r'Unreal Engine (\d+\.\d+(?:\.\d+)?)');
        final matches = regExp.allMatches(response.body);
        if (matches.isNotEmpty) {
          List<String> versions = matches.map((m) => m.group(1)!).toList();
          versions.sort((a, b) => Engine.compareVersions(b, a));
          return versions.first;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Failed to fetch latest UE version: $e');
    }
    return null;
  }

  Future<EngineModel?> _tryParseEngineInfo(Directory dir) async {
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
        bool isLaunchable = await executableFile.exists();
        return EngineModel(
          version: versionString,
          path: dir.path,
          executablePath: executablePath,
          isLaunchable: isLaunchable,
        );
      } catch (e) {
        if (kDebugMode) print('Error parsing Build.version in ${dir.path}: $e');
      }
    }
    return null;
  }
}
