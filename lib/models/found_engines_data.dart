import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ue_launcher/models/engine_locator.dart';
import 'package:ue_launcher/models/unreal_engine_info.dart';

class FoundEnginesData extends ChangeNotifier {
  List<UnrealEngineInfo> foundEngines = [];
  bool isLoading = false;

  final EngineLocator engineLocator = EngineLocator();

  static const _fileName = 'engines.json';

  Future<File> get _localFile async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> loadEngines() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        foundEngines = jsonList.map((j) => UnrealEngineInfo.fromJson(j)).toList();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Failed to load engines: $e');
    }
  }

  Future<void> saveEngines() async {
    try {
      final file = await _localFile;
      final jsonList = foundEngines.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      if (kDebugMode) print('Failed to save engines: $e');
    }
  }

  Future<void> tryLoadDefaultOrSavedEngine() async {
    isLoading = true;
    notifyListeners();

    await loadEngines();

    List<UnrealEngineInfo> defaultEngines = await engineLocator.checkDefaultEngineLocation();

    bool addedNew = false;
    for (final engine in defaultEngines) {
      if (!foundEngines.any((e) => e.path == engine.path)) {
        foundEngines.add(engine);
        addedNew = true;
      }
    }

    foundEngines.sort((a, b) => a.version.compareTo(b.version));

    if (addedNew) {
      await saveEngines();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> manuallyAddEngine() async {
    String? selectedPath = await engineLocator.pickEngineDirectory();

    if (selectedPath != null) {
      isLoading = true;
      notifyListeners();

      List<UnrealEngineInfo> newEngines = await engineLocator.getEngineInfoFromPath(selectedPath);

      bool addedNew = false;
      for (final engine in newEngines) {
        if (!foundEngines.any((e) => e.path == engine.path)) {
          foundEngines.add(engine);
          addedNew = true;
        }
      }

      if (addedNew) {
        foundEngines.sort((a, b) => a.version.compareTo(b.version));
        await saveEngines();
      }

      isLoading = false;
      notifyListeners();
    }
  }

  void removeEngine(UnrealEngineInfo engineToRemove) {
    foundEngines.removeWhere((engine) => engine.path == engineToRemove.path);
    saveEngines();
    notifyListeners();
  }
}
