import 'package:flutter/foundation.dart';
import 'package:ue_launcher/engine_locator.dart';
import 'package:ue_launcher/models/UnrealEngineInfo.dart';

class FoundEnginesData extends ChangeNotifier {
  List<UnrealEngineInfo> foundEngines = [];
  bool isLoading = false;

  final EngineLocator engineLocator = EngineLocator();

  Future<void> tryLoadDefaultOrSavedEngine() async {
    isLoading = true;
    notifyListeners();
    // TODO: In a real app, you'd load saved paths from SharedPreferences first. For now, just check a default location.
    List<UnrealEngineInfo?> defaultEngines = await engineLocator.checkDefaultEngineLocation();

    for (final engine in defaultEngines) {
      if (!foundEngines.any((e) => e.path == engine?.path)) {
        foundEngines.add(engine!);
      }
    }

    foundEngines.sort((a, b) => b.version.compareTo(a.version));

    isLoading = false;
    notifyListeners();
  }

  Future<void> manuallyAddEngine() async {
    isLoading = true;
    notifyListeners();

    String? selectedPath = await engineLocator.pickEngineDirectory();

    if (selectedPath != null) {
      List<UnrealEngineInfo?> newEngines = await engineLocator.getEngineInfoFromPath(selectedPath);

      for (final engine in newEngines) {
        if (!foundEngines.any((e) => e.path == engine?.path)) {
          foundEngines.add(engine!);
        }
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void removeEngine(UnrealEngineInfo engineToRemove) {
    foundEngines.removeWhere((engine) => engine.path == engineToRemove.path);
    // TODO: Optionally, remove from SharedPreferences
    notifyListeners();
  }
}
