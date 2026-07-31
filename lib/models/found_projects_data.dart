import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_pckg;
import 'package:path_provider/path_provider.dart';

import 'project_locator.dart';
import 'unreal_project_data.dart';

class FoundProjectsData extends ChangeNotifier {
  List<String> scannedFolders = [];
  List<UnrealProjectData> foundProjects = [];
  List<UnrealProjectData> filteredProjects = [];
  List<String> recentProjectPaths = [];
  String currentSearchQuery = '';
  List<String> selectedTags = [];

  bool isScanning = false;
  final ProjectLocator _projectLocator = ProjectLocator();

  bool sortedByName = false;
  bool sortedByDateCreated = false;
  bool sortedByDateModified = false;
  bool sortedByEngineVersion = false;

  static const _fileName = 'projects.json';

  Future<File> get _localFile async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> loadProjects() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        final contents = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(contents);

        final List<dynamic> projectList = data['projects'] ?? [];
        foundProjects = projectList.map((json) => UnrealProjectData.fromJson(json)).toList();
        filteredProjects = foundProjects;

        scannedFolders = List<String>.from(data['folders'] ?? []);
        recentProjectPaths = List<String>.from(data['recentPaths'] ?? []);
        notifyListeners();

        // Auto-rescan on launch to detect changes
        rescanAllFolders();
      }
    } catch (e) {
      if (kDebugMode) print('Failed to load projects: $e');
    }
  }

  Future<void> saveProjects() async {
    try {
      final file = await _localFile;
      final data = {
        'projects': foundProjects.map((p) => p.toJson()).toList(),
        'folders': scannedFolders,
        'recentPaths': recentProjectPaths,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      if (kDebugMode) print('Failed to save projects: $e');
    }
  }

  void addFolders(List<UnrealProjectData> projects, {String? scannedFolder}) {
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

    List<UnrealProjectData> allFound = [];
    for (String folder in scannedFolders) {
      if (await Directory(folder).exists()) {
        final projects = await _projectLocator.scanForUProjects(folder);
        allFound.addAll(projects);
      }
    }

    // Update foundProjects: Keep only what's still there, and add new ones
    // Merge tags from existing projects
    for (int i = 0; i < allFound.length; i++) {
      final existingProjectIndex = foundProjects.indexWhere((p) => p.path == allFound[i].path);
      if (existingProjectIndex != -1) {
        allFound[i] = allFound[i].copyWith(tags: foundProjects[existingProjectIndex].tags);
      }
    }

    foundProjects = allFound;
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

    if (await Directory(folderPath).exists()) {
      // Map existing tags to preserve them
      final Map<String, List<String>> existingTagsMap = {
        for (var p in foundProjects.where((p) => path_pckg.isWithin(folderPath, p.path))) p.path: p.tags,
      };

      // Remove projects that were previously in this folder
      foundProjects.removeWhere((p) => path_pckg.isWithin(folderPath, p.path));

      // Scan for projects in this folder
      final newProjects = await _projectLocator.scanForUProjects(folderPath);

      // Restore tags
      for (int i = 0; i < newProjects.length; i++) {
        if (existingTagsMap.containsKey(newProjects[i].path)) {
          newProjects[i] = newProjects[i].copyWith(tags: existingTagsMap[newProjects[i].path]);
        }
      }

      foundProjects.addAll(newProjects);

      _applyCurrentSort();
      _syncFilteredProjects();
    }

    isScanning = false;
    notifyListeners();
    saveProjects();
  }

  void _applyCurrentSort() {
    if (sortedByName) {
      foundProjects.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortedByDateCreated) {
      foundProjects.sort((a, b) => a.created.compareTo(b.created));
    } else if (sortedByDateModified) {
      foundProjects.sort((a, b) => a.modified.compareTo(b.modified));
    } else if (sortedByEngineVersion) {
      foundProjects.sort((a, b) => a.engineVersion.compareTo(b.engineVersion));
    } else {
      // Default sort
      foundProjects.sort((a, b) => b.modified.compareTo(a.modified));
    }
  }

  void removeFoldersFromPath(String path) {
    foundProjects.removeWhere((p) => p.path.contains(path));
    scannedFolders.removeWhere((folder) => folder == path);
    recentProjectPaths.removeWhere((pPath) => pPath.contains(path));
    notifyListeners();
    saveProjects();
  }

  void recordProjectLaunch(UnrealProjectData project) {
    // Remove if already exists to move to top
    recentProjectPaths.remove(project.path);
    // Add to top
    recentProjectPaths.insert(0, project.path);

    // Limit to 10
    if (recentProjectPaths.length > 10) {
      recentProjectPaths = recentProjectPaths.sublist(0, 10);
    }

    notifyListeners();
    saveProjects();
  }

  void searchForProjects(String searchQuery) {
    currentSearchQuery = searchQuery;
    if (searchQuery.isEmpty) {
      filteredProjects = List.from(foundProjects);
    } else {
      filteredProjects = foundProjects.where((project) {
        return project.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void cancelSearch() {
    currentSearchQuery = '';
    filteredProjects = List.from(foundProjects);
    notifyListeners();
  }

  void sortProjectsByName() {
    if (!sortedByName) {
      foundProjects.sort((a, b) => a.name.compareTo(b.name));
      sortedByName = true;
    } else {
      foundProjects.sort((a, b) => b.name.compareTo(a.name));
      sortedByName = false;
    }
    _syncFilteredProjects();
  }

  void sortProjectsByDateCreated() {
    if (!sortedByDateCreated) {
      foundProjects.sort((a, b) => a.created.compareTo(b.created));
      sortedByDateCreated = true;
    } else {
      foundProjects.sort((a, b) => b.created.compareTo(a.created));
      sortedByDateCreated = false;
    }
    _syncFilteredProjects();
  }

  void sortProjectsByDateModified() {
    if (!sortedByDateModified) {
      foundProjects.sort((a, b) => a.modified.compareTo(b.modified));
      sortedByDateModified = true;
    } else {
      foundProjects.sort((a, b) => b.modified.compareTo(a.modified));
      sortedByDateModified = false;
    }
    _syncFilteredProjects();
  }

  void sortProjectsByEngineVersion() {
    if (!sortedByEngineVersion) {
      foundProjects.sort((a, b) => a.engineVersion.compareTo(b.engineVersion));
      sortedByEngineVersion = true;
    } else {
      foundProjects.sort((a, b) => b.engineVersion.compareTo(a.engineVersion));
      sortedByEngineVersion = false;
    }
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

  void addTagToProject(UnrealProjectData project, String tag) {
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

  void removeTagFromProject(UnrealProjectData project, String tag) {
    final index = foundProjects.indexWhere((p) => p.path == project.path);
    if (index != -1) {
      final updatedTags = List<String>.from(foundProjects[index].tags);
      if (updatedTags.remove(tag)) {
        foundProjects[index] = foundProjects[index].copyWith(tags: updatedTags);
        _syncFilteredProjects();
        saveProjects();
      }
    }
  }
}
