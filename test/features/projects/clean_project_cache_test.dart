import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:ue_launcher/features/projects/domain/entities/project.dart';
import 'package:ue_launcher/features/projects/domain/usecases/clean_project_cache.dart';

void main() {
  late Directory tempDir;
  late CleanProjectCacheUseCase useCase;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ue_clean_test_');
    useCase = CleanProjectCacheUseCase();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('estimates cache size and removes cache folders', () async {
    final uprojectFile = File(p.join(tempDir.path, 'TestGame.uproject'));
    await uprojectFile.writeAsString('{}');

    final intermediateDir = Directory(p.join(tempDir.path, 'Intermediate'))..createSync();
    final savedDir = Directory(p.join(tempDir.path, 'Saved'))..createSync();
    final contentDir = Directory(p.join(tempDir.path, 'Content'))..createSync();

    File(p.join(intermediateDir.path, 'dummy.obj')).writeAsStringSync('1234567890'); // 10 bytes
    File(p.join(savedDir.path, 'log.txt')).writeAsStringSync('12345'); // 5 bytes
    File(p.join(contentDir.path, 'Asset.uasset')).writeAsStringSync('critical'); // Must NOT be deleted

    final project = Project(
      name: 'TestGame',
      path: uprojectFile.path,
      engineVersion: '5.4',
      created: DateTime.now(),
      modified: DateTime.now(),
    );

    final estimated = await useCase.estimateCacheSize(project);
    expect(estimated, 15);

    final result = await useCase(project);
    expect(result.bytesFreed, 15);
    expect(result.deletedFolders, contains('Intermediate'));
    expect(result.deletedFolders, contains('Saved'));

    expect(await intermediateDir.exists(), isFalse);
    expect(await savedDir.exists(), isFalse);
    expect(await contentDir.exists(), isTrue);
  });
}
