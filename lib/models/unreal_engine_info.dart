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
}
