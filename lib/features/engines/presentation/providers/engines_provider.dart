import 'package:flutter/foundation.dart';
import 'package:ue_launcher/core/di.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/engine.dart';

class EnginesProvider extends ChangeNotifier {
  List<Engine> foundEngines = [];
  bool isLoading = false;
  String? latestAvailableVersion;

  bool get isUpdateAvailable {
    if (latestAvailableVersion == null || foundEngines.isEmpty) return false;
    String highestInstalled = foundEngines.map((e) => e.version).reduce((a, b) {
      return Engine.compareVersions(a, b) >= 0 ? a : b;
    });
    return Engine.compareVersions(latestAvailableVersion!, highestInstalled) > 0;
  }

  Future<void> tryLoadDefaultOrSavedEngine() async {
    isLoading = true;
    notifyListeners();

    foundEngines = await DI.detectEnginesUseCase();

    isLoading = false;
    notifyListeners();
    checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    final version = await DI.checkEngineUpdatesUseCase();
    if (version != null) {
      latestAvailableVersion = version;
      notifyListeners();
    }
  }

  Future<void> triggerEngineInstallation(String version) async {
    final String uriString = version.isEmpty
        ? 'com.epicgames.launcher://ue/library'
        : 'com.epicgames.launcher://apps/UE_$version?action=installer';
    final Uri uri = Uri.parse(uriString);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final Uri libraryUri = Uri.parse('com.epicgames.launcher://ue/library');
      if (await canLaunchUrl(libraryUri)) {
        await launchUrl(libraryUri);
      }
    }
  }

  Future<void> manuallyAddEngine() async {
    String? selectedPath = await DI.pickerService.pickDirectory(
      dialogTitle: 'Please select your Unreal Engine installation directory',
    );

    if (selectedPath != null) {
      isLoading = true;
      notifyListeners();

      List<Engine> newEngines = await DI.engineRepository.getEnginesFromPath(selectedPath);

      bool addedNew = false;
      for (final engine in newEngines) {
        if (!foundEngines.any((e) => e.path == engine.path)) {
          foundEngines.add(engine);
          addedNew = true;
        }
      }

      if (addedNew) {
        foundEngines.sort((a, b) => Engine.compareVersions(a.version, b.version));
        await DI.engineRepository.saveEngines(foundEngines);
      }

      isLoading = false;
      notifyListeners();
    }
  }

  void removeEngine(Engine engineToRemove) {
    foundEngines.removeWhere((engine) => engine.path == engineToRemove.path);
    DI.engineRepository.saveEngines(foundEngines);
    notifyListeners();
  }
}
