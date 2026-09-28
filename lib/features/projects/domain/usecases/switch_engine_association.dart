import 'dart:convert';
import 'dart:io';
import '../entities/project.dart';

class SwitchEngineAssociationUseCase {
  Future<Project> call(Project project, String newEngineVersion) async {
    final file = File(project.path);
    if (!await file.exists()) {
      throw Exception('Project file not found: ${project.path}');
    }

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    json['EngineAssociation'] = newEngineVersion;

    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(json));

    return project.copyWith(engineVersion: newEngineVersion);
  }
}
