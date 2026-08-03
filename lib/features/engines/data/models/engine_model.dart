import '../../domain/entities/engine.dart';

class EngineModel extends Engine {
  EngineModel({
    required super.version,
    required super.path,
    required super.executablePath,
    super.isLaunchable = true,
  });

  factory EngineModel.fromJson(Map<String, dynamic> json) {
    return EngineModel(
      version: json['version'],
      path: json['path'],
      executablePath: json['executablePath'],
      isLaunchable: json['isLaunchable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'path': path,
        'executablePath': executablePath,
        'isLaunchable': isLaunchable,
      };

  factory EngineModel.fromEntity(Engine engine) {
    return EngineModel(
      version: engine.version,
      path: engine.path,
      executablePath: engine.executablePath,
      isLaunchable: engine.isLaunchable,
    );
  }
}
