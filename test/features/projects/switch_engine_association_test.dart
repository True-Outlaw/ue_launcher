import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:ue_launcher/features/projects/domain/entities/project.dart';
import 'package:ue_launcher/features/projects/domain/usecases/switch_engine_association.dart';

void main() {
  late Directory tempDir;
  late SwitchEngineAssociationUseCase useCase;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ue_switch_test_');
    useCase = SwitchEngineAssociationUseCase();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('switches EngineAssociation in .uproject and updates Project entity', () async {
    final uprojectFile = File(p.join(tempDir.path, 'TestGame.uproject'));
    await uprojectFile.writeAsString(jsonEncode({
      'FileVersion': 3,
      'EngineAssociation': '5.3',
      'Category': '',
      'Description': '',
    }));

    final project = Project(
      name: 'TestGame',
      path: uprojectFile.path,
      engineVersion: '5.3',
      created: DateTime.now(),
      modified: DateTime.now(),
    );

    final updated = await useCase(project, '5.4');

    expect(updated.engineVersion, '5.4');

    final updatedJson = jsonDecode(await uprojectFile.readAsString());
    expect(updatedJson['EngineAssociation'], '5.4');
  });
}
