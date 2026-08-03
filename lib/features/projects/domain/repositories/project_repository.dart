import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> scanDirectory(String path);
  Future<List<Project>> loadSavedProjects();
  Future<void> saveProjects(List<Project> projects, List<String> folders, List<String> recentPaths);
  Future<Map<String, dynamic>> loadPersistedData();
}
