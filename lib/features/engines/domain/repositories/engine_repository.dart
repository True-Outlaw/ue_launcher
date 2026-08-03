import '../entities/engine.dart';

abstract class EngineRepository {
  Future<List<Engine>> getEnginesFromPath(String path);
  Future<List<Engine>> getDefaultEngines();
  Future<List<Engine>> loadSavedEngines();
  Future<void> saveEngines(List<Engine> engines);
  Future<String?> fetchLatestVersion();
}
