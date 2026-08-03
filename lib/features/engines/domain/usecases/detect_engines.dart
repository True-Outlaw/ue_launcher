import '../entities/engine.dart';
import '../repositories/engine_repository.dart';

class DetectEnginesUseCase {
  final EngineRepository repository;

  DetectEnginesUseCase(this.repository);

  Future<List<Engine>> call() async {
    // 1. Load saved engines
    final savedEngines = await repository.loadSavedEngines();

    // 2. Check default locations
    final defaultEngines = await repository.getDefaultEngines();

    // 3. Merge
    final Map<String, Engine> engineMap = {
      for (var e in savedEngines) e.path: e,
      for (var e in defaultEngines) e.path: e,
    };

    final sortedEngines = engineMap.values.toList()..sort((a, b) => Engine.compareVersions(a.version, b.version));

    // 4. Save merged list
    await repository.saveEngines(sortedEngines);

    return sortedEngines;
  }
}
