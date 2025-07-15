import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as pathPckg;

import 'UnrealProjectData.dart';

class FoundProjectsData extends ChangeNotifier {
  List<UnrealProjectData> foundProjects = [];

  void removeProjectsFromPath(String path) {
    String pathToRemove = '${pathPckg.dirname(path)}\\${pathPckg.basename(path)}';
    foundProjects.removeWhere((project) => project.path.contains(pathToRemove));
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
