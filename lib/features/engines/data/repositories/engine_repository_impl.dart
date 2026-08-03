import '../../domain/entities/engine.dart';
import '../../domain/repositories/engine_repository.dart';
import '../datasources/local_engine_data_source.dart';
import '../models/engine_model.dart';

class EngineRepositoryImpl implements EngineRepository {
  final EngineDataSource dataSource;

  EngineRepositoryImpl(this.dataSource);

  @override
  Future<List<Engine>> getDefaultEngines() async {
    final models = await dataSource.getWindowsDefaultEngines();
    return models.map<Engine>((e) => e).toList();
  }

  @override
  Future<List<Engine>> getEnginesFromPath(String path) async {
    final models = await dataSource.scanForEngines(path, includeRoot: true);
    return models.map<Engine>((e) => e).toList();
  }

  @override
  Future<List<Engine>> loadSavedEngines() async {
    final models = await dataSource.loadSavedEngines();
    return models.map<Engine>((e) => e).toList();
  }

  @override
  Future<void> saveEngines(List<Engine> engines) async {
    await dataSource.saveEngines(engines.map((e) => EngineModel.fromEntity(e)).toList());
  }

  @override
  Future<String?> fetchLatestVersion() async {
    return await dataSource.fetchLatestVersion();
  }
}
