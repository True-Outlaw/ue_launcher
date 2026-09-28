import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:ue_launcher/features/projects/domain/entities/project.dart';
import 'package:ue_launcher/features/projects/domain/usecases/clone_project.dart';

void main() {
  late Directory tempDir;
  late CloneProjectUseCase useCase;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ue_launcher_test_');
    useCase = CloneProjectUseCase();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('clones project including Plugins, Config, Content, Source and ignores Binaries/Intermediate', () async {
    final sourceProjDir = Directory(p.join(tempDir.path, 'OriginalProject'));
    await sourceProjDir.create(recursive: true);

    // Create folders
    final configDir = Directory(p.join(sourceProjDir.path, 'Config'))..createSync();
    final contentDir = Directory(p.join(sourceProjDir.path, 'Content'))..createSync();
    final sourceDir = Directory(p.join(sourceProjDir.path, 'Source'))..createSync();
    final pluginsDir = Directory(p.join(sourceProjDir.path, 'Plugins', 'MyPlugin'))..createSync(recursive: true);
    final intermediateDir = Directory(p.join(sourceProjDir.path, 'Intermediate'))..createSync();

    // Create sample files
    File(p.join(configDir.path, 'DefaultEngine.ini')).writeAsStringSync('[Core]');
    File(p.join(contentDir.path, 'Asset.uasset')).writeAsStringSync('binary_data');
    File(p.join(sourceDir.path, 'Main.cpp')).writeAsStringSync('#include "Main.h"');
    File(p.join(pluginsDir.path, 'Plugin.uplugin')).writeAsStringSync('{}');
    File(p.join(intermediateDir.path, 'StaleBuild.obj')).writeAsStringSync('stale');

    final uprojectFile = File(p.join(sourceProjDir.path, 'OriginalProject.uproject'))
      ..writeAsStringSync('{"EngineAssociation": "5.4"}');

    final project = Project(
      name: 'OriginalProject',
      path: uprojectFile.path,
      engineVersion: '5.4',
      created: DateTime.now(),
      modified: DateTime.now(),
    );

    final targetParentDir = Directory(p.join(tempDir.path, 'Clones'))..createSync();

    await useCase(
      project,
      'ClonedProject',
      targetParentDir.path,
    );

    final clonedDir = Directory(p.join(targetParentDir.path, 'ClonedProject'));
    expect(await clonedDir.exists(), isTrue);

    // Cloned uproject file exists
    expect(File(p.join(clonedDir.path, 'ClonedProject.uproject')).existsSync(), isTrue);

    // Essential folders exist
    expect(File(p.join(clonedDir.path, 'Config', 'DefaultEngine.ini')).existsSync(), isTrue);
    expect(File(p.join(clonedDir.path, 'Content', 'Asset.uasset')).existsSync(), isTrue);
    expect(File(p.join(clonedDir.path, 'Source', 'Main.cpp')).existsSync(), isTrue);
    expect(File(p.join(clonedDir.path, 'Plugins', 'MyPlugin', 'Plugin.uplugin')).existsSync(), isTrue);

    // Non-essential folders must NOT be cloned
    expect(Directory(p.join(clonedDir.path, 'Intermediate')).existsSync(), isFalse);
  });
}
