import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'unreal_project_data.dart';

class FoundProjectsData extends ChangeNotifier {
  List<String> scannedFolders = [];
  List<UnrealProjectData> foundProjects = [];
  List<UnrealProjectData> filteredProjects = [];

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
        notifyListeners();
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
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      if (kDebugMode) print('Failed to save projects: $e');
    }
  }

  void addFolders(List<UnrealProjectData> projects, {String? scannedFolder}) {
    foundProjects.addAll(projects);
    sortProjectsByDateModified();

    if (scannedFolder != null && !scannedFolders.contains(scannedFolder)) {
      scannedFolders.add(scannedFolder);
    }

    notifyListeners();
    saveProjects();
  }

  void removeFoldersFromPath(String path) {
    foundProjects.removeWhere((p) => p.path.contains(path));
    scannedFolders.removeWhere((folder) => folder == path);
    notifyListeners();
    saveProjects();
  }

  void searchForProjects(String searchQuery) {
    filteredProjects = foundProjects.where((project) {
      return project.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    notifyListeners();
  }

  void cancelSearch() {
    filteredProjects = foundProjects;
    notifyListeners();
  }
  // void removeProjectsFromPath(String path) {
  //   foundProjects.removeWhere((project) => project.path.contains(path));
  //   notifyListeners();
  //   saveProjects();
  // }
  //
  // void removeProjects(List<UnrealProjectData> projects) {
  //   foundProjects.removeWhere((project) => projects.contains(project));
  //   notifyListeners();
  //   saveProjects();
  // }
  //
  // void addProject(UnrealProjectData project) {
  //   foundProjects.add(project);
  //   notifyListeners();
  //   saveProjects();
  // }
  //
  // void addProjects(List<UnrealProjectData> projects) {
  //   foundProjects.addAll(projects);
  //   notifyListeners();
  //   saveProjects();
  // }

  void sortProjectsByName() {
    if (!sortedByName) {
      foundProjects.sort((a, b) => a.name.compareTo(b.name));
      sortedByName = true;
    } else {
      foundProjects.sort((a, b) => b.name.compareTo(a.name));
      sortedByName = false;
    }
    notifyListeners();
  }

  void sortProjectsByDateCreated() {
    if (!sortedByDateCreated) {
      foundProjects.sort((a, b) => a.created.compareTo(b.created));
      sortedByDateCreated = true;
    } else {
      foundProjects.sort((a, b) => b.created.compareTo(a.created));
      sortedByDateCreated = false;
    }
    notifyListeners();
  }

  void sortProjectsByDateModified() {
    if (!sortedByDateModified) {
      foundProjects.sort((a, b) => a.modified.compareTo(b.created));
      sortedByDateModified = true;
    } else {
      foundProjects.sort((a, b) => b.modified.compareTo(a.created));
      sortedByDateModified = false;
    }
    notifyListeners();
  }

  void sortProjectsByEngineVersion() {
    if (!sortedByEngineVersion) {
      foundProjects.sort((a, b) => a.engineVersion.compareTo(b.engineVersion));
      sortedByEngineVersion = true;
    } else {
      foundProjects.sort((a, b) => b.engineVersion.compareTo(a.engineVersion));
      sortedByEngineVersion = false;
    }
    notifyListeners();
  }
}
