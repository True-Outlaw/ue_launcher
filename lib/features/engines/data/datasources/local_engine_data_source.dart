import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path_pckg;
import 'package:path_provider/path_provider.dart';
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
      const defaultWindowsPaths = ['C:\\Program Files\\Epic Games'];
      for (final path in defaultWindowsPaths) {
        final found = await scanForEngines(path, includeRoot: false);
        results.addAll(found);
      }
    }
    return results;
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
