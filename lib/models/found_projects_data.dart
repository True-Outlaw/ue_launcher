import 'package:flutter/foundation.dart';

import 'unreal_project_data.dart';

class FoundProjectsData extends ChangeNotifier {
  List<UnrealProjectData> foundProjects = [];
  bool sortedByName = false;
  bool sortedByDateCreated = false;
  bool sortedByDateModified = false;
  bool sortedByEngineVersion = false;

  void removeProjectsFromPath(String path) {
    foundProjects.removeWhere((project) => project.path.contains(path));
    notifyListeners();
  }

  void removeProjects(List<UnrealProjectData> projects) {
    foundProjects.removeWhere((project) => projects.contains(project));
    notifyListeners();
  }

  void addProject(UnrealProjectData project) {
    foundProjects.add(project);
    notifyListeners();
  }

  void addProjects(List<UnrealProjectData> projects) {
    foundProjects.addAll(projects);
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
