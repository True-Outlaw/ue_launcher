import 'package:flutter/foundation.dart';
import 'package:ue_launcher/core/di.dart';

import '../../domain/entities/project.dart';

enum SortField { name, dateCreated, dateModified, engineVersion }

class ProjectsProvider extends ChangeNotifier {
  List<String> scannedFolders = [];
  List<Project> foundProjects = [];
  List<Project> filteredProjects = [];
  List<String> recentProjectPaths = [];
  String currentSearchQuery = '';
  List<String> selectedTags = [];

  bool isScanning = false;

  SortField activeSortField = SortField.dateModified;
  bool sortAscending = false;

  Future<void> loadProjects() async {
    final data = await DI.projectRepository.loadPersistedData();

    // We rely on repository to give us projects, but we need to handle the conversion here or in repository
    // RepositoryImpl already handles it.
    foundProjects = await DI.projectRepository.loadSavedProjects();
    filteredProjects = foundProjects;

    scannedFolders = List<String>.from(data['folders'] ?? []);
    recentProjectPaths = List<String>.from(data['recentPaths'] ?? []);
    notifyListeners();

    // Auto-rescan on launch
    rescanAllFolders();
  }

  Future<void> saveProjects() async {
    await DI.projectRepository.saveProjects(foundProjects, scannedFolders, recentProjectPaths);
  }

  void addFolders(List<Project> projects, {String? scannedFolder}) {
    for (var project in projects) {
      if (!foundProjects.any((p) => p.path == project.path)) {
        foundProjects.add(project);
      }
    }
    sortProjectsByDateModified();

    if (scannedFolder != null && !scannedFolders.contains(scannedFolder)) {
      scannedFolders.add(scannedFolder);
    }

    notifyListeners();
    saveProjects();
  }

  Future<void> rescanAllFolders() async {
    if (isScanning) return;
    isScanning = true;
    notifyListeners();

    foundProjects = await DI.scanProjectsUseCase(scannedFolders, foundProjects);

    _applyCurrentSort();
    _syncFilteredProjects();

    isScanning = false;
    notifyListeners();
    saveProjects();
  }

  Future<void> rescanFolder(String folderPath) async {
    if (isScanning) return;
    isScanning = true;
    notifyListeners();

    // Re-use scanProjectsUseCase for a single folder if we want, or adjust use case
    final newInFolder = await DI.projectRepository.scanDirectory(folderPath);

    // Logic from original FoundProjectsData.rescanFolder
    final Map<String, List<String>> existingTagsMap = {
      for (var p in foundProjects.where((p) => p.path.contains(folderPath))) p.path: p.tags,
    };

    foundProjects.removeWhere((p) => p.path.contains(folderPath));

    final updatedNew = newInFolder.map((p) {
      if (existingTagsMap.containsKey(p.path)) {
        return p.copyWith(tags: existingTagsMap[p.path]);
      }
      return p;
    }).toList();

    foundProjects.addAll(updatedNew);

    _applyCurrentSort();
    _syncFilteredProjects();

    isScanning = false;
    notifyListeners();
    saveProjects();
  }

  void _applyCurrentSort() {
    switch (activeSortField) {
      case SortField.name:
        foundProjects.sort((a, b) => sortAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
        break;
      case SortField.dateCreated:
        foundProjects.sort((a, b) => sortAscending ? a.created.compareTo(b.created) : b.created.compareTo(a.created));
        break;
      case SortField.dateModified:
        foundProjects.sort(
          (a, b) => sortAscending ? a.modified.compareTo(b.modified) : b.modified.compareTo(a.modified),
        );
        break;
      case SortField.engineVersion:
        foundProjects.sort(
          (a, b) =>
              sortAscending ? a.engineVersion.compareTo(b.engineVersion) : b.engineVersion.compareTo(a.engineVersion),
        );
        break;
    }
  }

  void removeFoldersFromPath(String path) {
    foundProjects.removeWhere((p) => p.path.contains(path));
    scannedFolders.removeWhere((folder) => folder == path);
    recentProjectPaths.removeWhere((pPath) => pPath.contains(path));
    notifyListeners();
    saveProjects();
  }

  void recordProjectLaunch(Project project) {
    recentProjectPaths.remove(project.path);
    recentProjectPaths.insert(0, project.path);
    if (recentProjectPaths.length > 10) {
      recentProjectPaths = recentProjectPaths.sublist(0, 10);
    }
    notifyListeners();
    saveProjects();
  }

  void searchForProjects(String searchQuery) {
    currentSearchQuery = searchQuery;
    _syncFilteredProjects();
  }

  void cancelSearch() {
    currentSearchQuery = '';
    _syncFilteredProjects();
  }

  void sortProjectsByName() => _updateSort(SortField.name, true);
  void sortProjectsByDateCreated() => _updateSort(SortField.dateCreated, false);
  void sortProjectsByDateModified() => _updateSort(SortField.dateModified, false);
  void sortProjectsByEngineVersion() => _updateSort(SortField.engineVersion, false);

  void _updateSort(SortField field, bool defaultAscending) {
    if (activeSortField == field) {
      sortAscending = !sortAscending;
    } else {
      activeSortField = field;
      sortAscending = defaultAscending;
    }
    _applyCurrentSort();
    _syncFilteredProjects();
  }

  void _syncFilteredProjects() {
    filteredProjects = foundProjects.where((project) {
      final matchesSearch =
          currentSearchQuery.isEmpty || project.name.toLowerCase().contains(currentSearchQuery.toLowerCase());
      final matchesTags = selectedTags.isEmpty || selectedTags.any((tag) => project.tags.contains(tag));
      return matchesSearch && matchesTags;
    }).toList();
    notifyListeners();
  }

  List<String> get allUniqueTags {
    final tags = <String>{};
    for (var project in foundProjects) {
      tags.addAll(project.tags);
    }
    return tags.toList()..sort();
  }

  void toggleTagFilter(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    _syncFilteredProjects();
  }

  void addTagToProject(Project project, String tag) {
    final index = foundProjects.indexWhere((p) => p.path == project.path);
    if (index != -1) {
      final updatedTags = List<String>.from(foundProjects[index].tags);
      if (!updatedTags.contains(tag)) {
        updatedTags.add(tag);
        foundProjects[index] = foundProjects[index].copyWith(tags: updatedTags);
        _syncFilteredProjects();
        saveProjects();
      }
    }
  }

  void removeTagFromProject(Project project, String tag) {
    final index = foundProjects.indexWhere((p) => p.path == project.path);
    if (index != -1) {
      final updatedTags = List<String>.from(foundProjects[index].tags);
      if (updatedTags.remove(tag)) {
        foundProjects[index] = foundProjects[index].copyWith(tags: updatedTags);
        if (selectedTags.contains(tag)) selectedTags.clear();
        _syncFilteredProjects();
        saveProjects();
      }
    }
  }
}
