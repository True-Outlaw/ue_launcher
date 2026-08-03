import '../repositories/engine_repository.dart';

class CheckEngineUpdatesUseCase {
  final EngineRepository repository;

  CheckEngineUpdatesUseCase(this.repository);

  Future<String?> call() async {
    return await repository.fetchLatestVersion();
  }
}
