import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/vault_asset.dart';

abstract class VaultDataSource {
  Future<List<VaultAsset>> scanVault({String? customPath});
  Future<void> deleteAsset(VaultAsset asset);
  String getDefaultVaultPath();
}

class LocalVaultDataSource implements VaultDataSource {
  @override
  String getDefaultVaultPath() {
    final programData = Platform.environment['PROGRAMDATA'] ?? r'C:\ProgramData';
    return p.join(programData, 'Epic', 'EpicGamesLauncher', 'VaultCache');
  }

  @override
  Future<List<VaultAsset>> scanVault({String? customPath}) async {
    final rootPath = customPath ?? getDefaultVaultPath();
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return [];

    final List<VaultAsset> assets = [];

    try {
      await for (final entity in rootDir.list(followLinks: false)) {
        if (entity is Directory) {
          final baseName = p.basename(entity.path);
          if (baseName.toLowerCase() == 'pending' || baseName.startsWith('.')) {
            continue;
          }

          if (baseName.toLowerCase() == 'fablibrary') {
            // Fab Library items are nested inside FabLibrary/
            await for (final fabEntity in entity.list(followLinks: false)) {
              if (fabEntity is Directory) {
                final asset = await _parseVaultFolder(fabEntity);
                if (asset != null) assets.add(asset);
              }
            }
          } else {
            final asset = await _parseVaultFolder(entity);
            if (asset != null) assets.add(asset);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error scanning vault cache: $e');
    }

    assets.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    return assets;
  }

  Future<VaultAsset?> _parseVaultFolder(Directory dir) async {
    try {
      int totalSize = 0;
      String? foundThumbnail;
      String displayName = p.basename(dir.path);

      await for (final file in dir.list(recursive: true, followLinks: false)) {
        if (file is File) {
          totalSize += await file.length();

          final lower = file.path.toLowerCase();
          if (foundThumbnail == null && (lower.endsWith('.png') || lower.endsWith('.jpg'))) {
            if (!lower.contains('cache') && !lower.contains('intermediate')) {
              foundThumbnail = file.path;
            }
          }

          if (file.path.endsWith('.mancpn') || p.basename(file.path) == 'manifest') {
            try {
              final content = await file.readAsString();
              final json = jsonDecode(content);
              final name = json['AppName'] ?? json['CatalogItemId'];
              if (name != null && name.toString().isNotEmpty) {
                displayName = name.toString();
              }
            } catch (_) {}
          }
        }
      }

      // Prettify name if it looks like Fab or GUID suffix
      if (displayName.contains('-') && displayName.length > 20) {
        final parts = displayName.split('-');
        if (parts.length > 1 && parts.last.length == 8) {
          displayName = parts.sublist(0, parts.length - 1).join(' ').replaceAll('_', ' ').trim();
        }
      }

      return VaultAsset(
        name: displayName,
        path: dir.path,
        sizeBytes: totalSize,
        thumbnailPath: foundThumbnail,
      );
    } catch (e) {
      if (kDebugMode) print('Error parsing vault folder ${dir.path}: $e');
      return null;
    }
  }

  @override
  Future<void> deleteAsset(VaultAsset asset) async {
    final dir = Directory(asset.path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
