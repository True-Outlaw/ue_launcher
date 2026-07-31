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
    // We want to preserve state if possible, but UnrealProjectData doesn't have much mutable state yet.
    // For now, let's just replace the list but keep the current sort.

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
      // Remove projects that were previously in this folder
      foundProjects.removeWhere((p) => path_pckg.isWithin(folderPath, p.path));

      // Scan for projects in this folder
      final newProjects = await _projectLocator.scanForUProjects(folderPath);
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
    if (currentSearchQuery.isEmpty) {
      filteredProjects = List.from(foundProjects);
    } else {
      filteredProjects = foundProjects.where((project) {
        return project.name.toLowerCase().contains(currentSearchQuery.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}
