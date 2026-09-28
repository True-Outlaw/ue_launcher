class VaultAsset {
  final String name;
  final String path;
  final int sizeBytes;
  final String? thumbnailPath;

  const VaultAsset({
    required this.name,
    required this.path,
    required this.sizeBytes,
    this.thumbnailPath,
  });

  String get formattedSize {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VaultAsset && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}
