import 'package:flutter/foundation.dart';

import 'UnrealProjectData.dart';

class FoundProjectsData extends ChangeNotifier {
  List<UnrealProjectData> foundProjects = [];
  bool sorted = false;

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

  void sortProjectsByNameDescending() {
    if (!sorted) {
      foundProjects.sort((a, b) => a.name.compareTo(b.name));
      sorted = true;
    } else {
      foundProjects.sort((a, b) => b.name.compareTo(a.name));
      sorted = false;
    }
    notifyListeners();
  }
}
