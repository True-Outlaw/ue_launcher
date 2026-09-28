import '../entities/vault_asset.dart';
import '../repositories/vault_repository.dart';

class GetVaultAssetsUseCase {
  final VaultRepository repository;

  GetVaultAssetsUseCase(this.repository);

  Future<List<VaultAsset>> call({String? customPath}) async {
    return await repository.getVaultAssets(customPath: customPath);
  }
}
