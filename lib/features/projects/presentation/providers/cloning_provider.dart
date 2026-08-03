import 'package:flutter/foundation.dart';
import 'package:ue_launcher/core/di.dart';
import '../../domain/entities/project.dart';
import 'projects_provider.dart';

class CloningProvider extends ChangeNotifier {
  bool _isCloning = false;
  String _currentProjectName = '';
  String _statusMessage = '';
  double _progress = 0;

  bool get isCloning => _isCloning;
  String get currentProjectName => _currentProjectName;
  String get statusMessage => _statusMessage;
  double get progress => _progress;

  Future<void> startClone(
    Project source,
    String newName,
    String targetParentPath,
    ProjectsProvider projectsProvider,
  ) async {
    if (_isCloning) return;

    _isCloning = true;
    _currentProjectName = newName;
    _statusMessage = 'Starting clone...';
    _progress = 0;
    notifyListeners();

    try {
      await DI.cloneProjectUseCase(
        source,
        newName,
        targetParentPath,
        onProgress: (message, progressValue) {
          _statusMessage = message;
          _progress = progressValue;
          notifyListeners();
        },
      );

      await projectsProvider.rescanFolder(targetParentPath);
      _statusMessage = 'Success';
    } catch (e) {
      _statusMessage = 'Error: $e';
      if (kDebugMode) print('Cloning error: $e');
    } finally {
      await Future.delayed(const Duration(seconds: 3));
      _isCloning = false;
      _currentProjectName = '';
      _statusMessage = '';
      notifyListeners();
    }
  }
}
