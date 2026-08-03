import '../entities/project.dart';
import '../repositories/project_repository.dart';

class ScanProjectsUseCase {
  final ProjectRepository repository;

  ScanProjectsUseCase(this.repository);

  Future<List<Project>> call(List<String> folders, List<Project> existingProjects) async {
    List<Project> allFound = [];
    for (String folder in folders) {
      final projects = await repository.scanDirectory(folder);
      allFound.addAll(projects);
    }

    // Merge tags from existing projects
    for (int i = 0; i < allFound.length; i++) {
      final existingProjectIndex = existingProjects.indexWhere((p) => p.path == allFound[i].path);
      if (existingProjectIndex != -1) {
        allFound[i] = allFound[i].copyWith(tags: existingProjects[existingProjectIndex].tags);
      }
    }

    return allFound;
  }
}
