import 'package:flutter_test/flutter_test.dart';
import 'package:ue_launcher/features/vault/domain/entities/vault_asset.dart';

void main() {
  group('VaultAsset', () {
    test('formats size correctly for various quantities', () {
      const bAsset = VaultAsset(name: 'Small', path: 'C:/Vault/Small', sizeBytes: 500);
      expect(bAsset.formattedSize, '0 KB');

      const kbAsset = VaultAsset(name: 'KBAsset', path: 'C:/Vault/KB', sizeBytes: 50 * 1024);
      expect(kbAsset.formattedSize, '50 KB');

      const mbAsset = VaultAsset(name: 'MBAsset', path: 'C:/Vault/MB', sizeBytes: 250 * 1024 * 1024);
      expect(mbAsset.formattedSize, '250.0 MB');

      final gbAsset = VaultAsset(name: 'GBAsset', path: 'C:/Vault/GB', sizeBytes: (15.5 * 1024 * 1024 * 1024).toInt());
      expect(gbAsset.formattedSize, '15.50 GB');
    });

    test('equality checks path matching', () {
      const asset1 = VaultAsset(name: 'PackA', path: 'C:/Vault/PackA', sizeBytes: 100);
      const asset2 = VaultAsset(name: 'PackA Duplicate', path: 'C:/Vault/PackA', sizeBytes: 200);
      const asset3 = VaultAsset(name: 'PackB', path: 'C:/Vault/PackB', sizeBytes: 100);

      expect(asset1 == asset2, isTrue);
      expect(asset1 == asset3, isFalse);
    });
  });
}
