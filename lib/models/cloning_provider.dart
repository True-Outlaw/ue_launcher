import 'dart:io';

import 'package:flutter/foundation.dart';

import 'found_projects_data.dart';
import 'project_cloner.dart';
import 'unreal_project_data.dart';

class CloningProvider extends ChangeNotifier {
  bool _isCloning = false;
  String _currentProjectName = '';
  String _statusMessage = '';
  double _progress = 0;

  bool get isCloning => _isCloning;
  String get currentProjectName => _currentProjectName;
  String get statusMessage => _statusMessage;
  double get progress => _progress;

  final ProjectCloner _projectCloner = ProjectCloner();

  Future<void> startClone(
    UnrealProjectData source,
    String newName,
    String targetParentPath,
    FoundProjectsData projectsData,
  ) async {
    if (_isCloning) return;

    _isCloning = true;
    _currentProjectName = newName;
    _statusMessage = 'Starting clone...';
    _progress = 0;
    notifyListeners();

    try {
      await _projectCloner.cloneProject(
        source,
        newName,
        targetParentPath,
        onProgress: (message, progressValue) {
          _statusMessage = message;
          _progress = progressValue;
          notifyListeners();
        },
      );

      // Trigger rescan of the parent directory of the new project
      await projectsData.rescanFolder(targetParentPath);

      _statusMessage = 'Success';
    } catch (e) {
      _statusMessage = 'Error: $e';
      if (kDebugMode) print('Cloning error: $e');
    } finally {
      // Keep the success/error message visible for a moment
      await Future.delayed(const Duration(seconds: 3));
      _isCloning = false;
      _currentProjectName = '';
      _statusMessage = '';
      notifyListeners();
    }
  }
}
