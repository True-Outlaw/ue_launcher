import '../../domain/entities/vault_asset.dart';
import '../../domain/repositories/vault_repository.dart';
import '../datasources/local_vault_data_source.dart';

class VaultRepositoryImpl implements VaultRepository {
  final VaultDataSource dataSource;

  VaultRepositoryImpl(this.dataSource);

  @override
  Future<List<VaultAsset>> getVaultAssets({String? customPath}) async {
    return await dataSource.scanVault(customPath: customPath);
  }

  @override
  Future<void> deleteVaultAsset(VaultAsset asset) async {
    await dataSource.deleteAsset(asset);
  }

  @override
  String getDefaultVaultPath() {
    return dataSource.getDefaultVaultPath();
  }
}
