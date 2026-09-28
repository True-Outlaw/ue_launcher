import '../entities/vault_asset.dart';
import '../repositories/vault_repository.dart';

class DeleteVaultAssetUseCase {
  final VaultRepository repository;

  DeleteVaultAssetUseCase(this.repository);

  Future<void> call(VaultAsset asset) async {
    await repository.deleteVaultAsset(asset);
  }
}
