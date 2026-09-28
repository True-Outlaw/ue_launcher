import 'package:flutter/material.dart';
import 'package:ue_launcher/features/engines/presentation/widgets/installed_engines_view.dart';
import 'package:ue_launcher/features/projects/presentation/widgets/projects_view.dart';
import 'package:ue_launcher/features/vault/presentation/widgets/vault_cache_view.dart';

class RightColumn extends StatefulWidget {
  const RightColumn({super.key});

  @override
  State<RightColumn> createState() => _RightColumnState();
}

class _RightColumnState extends State<RightColumn> {
  int _selectedTabIndex = 0; // 0 = Projects, 1 = Vault Cache

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Navigation Tab Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
          child: Row(
            children: [
              _buildNavTab(
                index: 0,
                label: 'Projects',
                icon: Icons.workspaces_outline,
              ),
              const SizedBox(width: 8),
              _buildNavTab(
                index: 1,
                label: 'Vault Cache',
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (_selectedTabIndex == 0) ...[
          const InstalledEngines(),
          const Expanded(
            flex: 3,
            child: ProjectsWindow(),
          ),
        ] else ...[
          const Expanded(
            child: VaultCacheView(),
          ),
        ],
      ],
    );
  }

  Widget _buildNavTab({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
