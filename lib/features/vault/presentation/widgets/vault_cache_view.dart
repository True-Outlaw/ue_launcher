import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/vault_asset.dart';
import '../providers/vault_provider.dart';

class VaultCacheView extends StatefulWidget {
  const VaultCacheView({super.key});

  @override
  State<VaultCacheView> createState() => _VaultCacheViewState();
}

class _VaultCacheViewState extends State<VaultCacheView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaultProvider>().loadVault();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFolder(String path) async {
    final uri = Uri.directory(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _confirmDelete(BuildContext context, VaultAsset asset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vault Asset'),
        content: Text(
          'Are you sure you want to delete "${asset.name}" (${asset.formattedSize})?\n\nThis will free up disk space. You can re-download this asset anytime from the Epic Games Launcher or Fab.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<VaultProvider>().deleteAsset(asset);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${asset.name}"')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VaultProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vault Cache',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total Cache: ${provider.formattedTotalSize} (${provider.assets.length} items)',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 240,
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search vault assets...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.search('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onChanged: provider.search,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    tooltip: 'Open Vault Cache folder',
                    onPressed: () => _openFolder(provider.vaultPath),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Vault Cache',
                    onPressed: provider.isLoading ? null : () => provider.loadVault(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Body
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Scanning Vault Cache...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : provider.assets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).hintColor),
                              const SizedBox(height: 12),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'No cached assets found in Vault'
                                    : 'No assets matching "${_searchController.text}"',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.vaultPath,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 260,
                            childAspectRatio: 0.82,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: provider.assets.length,
                          itemBuilder: (context, index) {
                            final asset = provider.assets[index];
                            return _VaultAssetCard(
                              asset: asset,
                              onOpenFolder: () => _openFolder(asset.path),
                              onDelete: () => _confirmDelete(context, asset),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _VaultAssetCard extends StatelessWidget {
  final VaultAsset asset;
  final VoidCallback onOpenFolder;
  final VoidCallback onDelete;

  const _VaultAssetCard({
    required this.asset,
    required this.onOpenFolder,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (asset.thumbnailPath != null)
                  Image.file(
                    File(asset.thumbnailPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _defaultThumbnail(context),
                  )
                else
                  _defaultThumbnail(context),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      asset.formattedSize,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.folder_open, size: 18),
                  tooltip: 'Open folder',
                  onPressed: onOpenFolder,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  tooltip: 'Delete asset',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultThumbnail(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.04),
      child: Icon(
        Icons.inventory_2_outlined,
        size: 48,
        color: Theme.of(context).hintColor,
      ),
    );
  }
}
