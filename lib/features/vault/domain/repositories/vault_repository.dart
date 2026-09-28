import '../entities/vault_asset.dart';

abstract class VaultRepository {
  Future<List<VaultAsset>> getVaultAssets({String? customPath});
  Future<void> deleteVaultAsset(VaultAsset asset);
  String getDefaultVaultPath();
}
