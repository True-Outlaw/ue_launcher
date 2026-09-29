import 'package:flutter/foundation.dart';
import '../../../../core/di.dart';
import '../../domain/entities/vault_asset.dart';

class VaultProvider extends ChangeNotifier {
  List<VaultAsset> _assets = [];
  List<VaultAsset> _filteredAssets = [];
  bool _isLoading = false;
  bool hasLoaded = false;
  String _searchQuery = '';

  List<VaultAsset> get assets => _filteredAssets;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  int get totalBytes => _assets.fold<int>(0, (sum, a) => sum + a.sizeBytes);

  String get formattedTotalSize {
    final bytes = totalBytes;
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
  }

  String get vaultPath => DI.vaultRepository.getDefaultVaultPath();

  Future<void> loadVault({bool forceRefresh = false}) async {
    if (hasLoaded && !forceRefresh) return;
    _isLoading = true;
    notifyListeners();

    try {
      _assets = await DI.getVaultAssetsUseCase();
      _filter();
      hasLoaded = true;
    } catch (e) {
      if (kDebugMode) print('Failed to load vault assets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _filter();
    notifyListeners();
  }

  void _filter() {
    if (_searchQuery.isEmpty) {
      _filteredAssets = List.from(_assets);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredAssets = _assets.where((a) => a.name.toLowerCase().contains(q)).toList();
    }
  }

  Future<void> deleteAsset(VaultAsset asset) async {
    await DI.deleteVaultAssetUseCase(asset);
    _assets.removeWhere((a) => a.path == asset.path);
    _filter();
    notifyListeners();
  }
}
