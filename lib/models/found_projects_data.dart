import 'package:flutter/foundation.dart';

import 'UnrealProjectData.dart';

class FoundProjectsData extends ChangeNotifier {
  List<UnrealProjectData> foundProjects = [];

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
}
