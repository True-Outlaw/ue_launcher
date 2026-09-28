import 'package:flutter_test/flutter_test.dart';
import 'package:ue_launcher/features/projects/data/models/project_model.dart';
import 'package:ue_launcher/features/projects/domain/entities/project.dart';

void main() {
  group('ProjectModel', () {
    final now = DateTime.now();
    final testJson = {
      'name': 'MyGame',
      'path': 'C:/Projects/MyGame/MyGame.uproject',
      'created': now.toIso8601String(),
      'modified': now.toIso8601String(),
      'engineVersion': '5.4',
      'thumbnailPath': 'C:/Projects/MyGame/Saved/AutoScreenshot.png',
      'tags': ['FPS', 'Multiplayer'],
    };

    test('fromJson deserializes correctly', () {
      final model = ProjectModel.fromJson(testJson);

      expect(model.name, 'MyGame');
      expect(model.path, 'C:/Projects/MyGame/MyGame.uproject');
      expect(model.engineVersion, '5.4');
      expect(model.thumbnailPath, 'C:/Projects/MyGame/Saved/AutoScreenshot.png');
      expect(model.tags, ['FPS', 'Multiplayer']);
    });

    test('toJson serializes correctly', () {
      final model = ProjectModel.fromJson(testJson);
      final json = model.toJson();

      expect(json['name'], 'MyGame');
      expect(json['path'], 'C:/Projects/MyGame/MyGame.uproject');
      expect(json['engineVersion'], '5.4');
      expect(json['tags'], ['FPS', 'Multiplayer']);
    });

    test('fromEntity converts correctly', () {
      final entity = Project(
        name: 'RPGGame',
        path: 'C:/Projects/RPGGame/RPGGame.uproject',
        engineVersion: '5.3',
        created: now,
        modified: now,
        tags: ['RPG'],
      );

      final model = ProjectModel.fromEntity(entity);
      expect(model.name, entity.name);
      expect(model.path, entity.path);
      expect(model.engineVersion, entity.engineVersion);
      expect(model.tags, entity.tags);
    });
  });
}
