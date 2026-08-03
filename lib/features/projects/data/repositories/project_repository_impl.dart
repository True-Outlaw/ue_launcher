import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/local_project_data_source.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectDataSource dataSource;

  ProjectRepositoryImpl(this.dataSource);

  @override
  Future<List<Project>> loadSavedProjects() async {
    final data = await dataSource.loadProjects();
    final List<dynamic> projectList = data['projects'] ?? [];
    return projectList.map<Project>((json) => ProjectModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> loadPersistedData() async {
    return await dataSource.loadProjects();
  }

  @override
  Future<void> saveProjects(List<Project> projects, List<String> folders, List<String> recentPaths) async {
    final data = {
      'projects': projects.map((p) => ProjectModel.fromEntity(p).toJson()).toList(),
      'folders': folders,
      'recentPaths': recentPaths,
    };
    await dataSource.saveProjects(data);
  }

  @override
  Future<List<Project>> scanDirectory(String path) async {
    final models = await dataSource.scanForUProjects(path);
    return models.map<Project>((e) => e).toList();
  }
}
