import 'package:ue_launcher/core/picker_service.dart';

import '../features/engines/data/datasources/local_engine_data_source.dart';
import '../features/engines/data/repositories/engine_repository_impl.dart';
import '../features/engines/domain/repositories/engine_repository.dart';
import '../features/engines/domain/usecases/check_engine_updates.dart';
import '../features/engines/domain/usecases/detect_engines.dart';
import '../features/projects/data/datasources/local_project_data_source.dart';
import '../features/projects/data/repositories/project_repository_impl.dart';
import '../features/projects/domain/repositories/project_repository.dart';
import '../features/projects/domain/usecases/clone_project.dart';
import '../features/projects/domain/usecases/scan_projects.dart';

class DI {
  static late final ProjectRepository projectRepository;
  static late final EngineRepository engineRepository;
  static late final PickerService pickerService;

  static late final ScanProjectsUseCase scanProjectsUseCase;
  static late final CloneProjectUseCase cloneProjectUseCase;
  static late final DetectEnginesUseCase detectEnginesUseCase;
  static late final CheckEngineUpdatesUseCase checkEngineUpdatesUseCase;

  static void init() {
    pickerService = PickerService();

    final projectDataSource = LocalProjectDataSource();
    projectRepository = ProjectRepositoryImpl(projectDataSource);
    scanProjectsUseCase = ScanProjectsUseCase(projectRepository);
    cloneProjectUseCase = CloneProjectUseCase();

    final engineDataSource = LocalEngineDataSource();
    engineRepository = EngineRepositoryImpl(engineDataSource);
    detectEnginesUseCase = DetectEnginesUseCase(engineRepository);
    checkEngineUpdatesUseCase = CheckEngineUpdatesUseCase(engineRepository);
  }
}
