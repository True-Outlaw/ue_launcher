class UnrealEngineInfo {
  final String version;
  final String path;
  final String executablePath;
  final bool isLaunchable;

  UnrealEngineInfo({
    required this.version,
    required this.path,
    required this.executablePath,
    this.isLaunchable = true,
  });

  factory UnrealEngineInfo.fromJson(Map<String, dynamic> json) {
    return UnrealEngineInfo(
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

  /// Compares two version strings (e.g., "5.8.1" and "5.3").
  /// Returns 1 if v1 > v2, -1 if v1 < v2, and 0 if they are equal.
  static int compareVersions(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    int maxLength = v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;

    for (int i = 0; i < maxLength; i++) {
      int v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      int v2Part = i < v2Parts.length ? v2Parts[i] : 0;

      if (v1Part > v2Part) return 1;
      if (v1Part < v2Part) return -1;
    }

    return 0;
  }
}
