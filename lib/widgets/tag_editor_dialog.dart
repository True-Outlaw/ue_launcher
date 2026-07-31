import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/found_projects_data.dart';
import '../models/unreal_project_data.dart';

class TagEditorDialog extends StatefulWidget {
  final UnrealProjectData project;

  const TagEditorDialog({super.key, required this.project});

  @override
  State<TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<TagEditorDialog> {
  final TextEditingController _tagController = TextEditingController();

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      context.read<FoundProjectsData>().addTagToProject(widget.project, tag);
      _tagController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // We need to get the latest project data from the provider because tags might have changed
    final currentProject = context.watch<FoundProjectsData>().foundProjects.firstWhere(
      (p) => p.path == widget.project.path,
      orElse: () => widget.project,
    );

    return AlertDialog(
      title: Text('Edit Tags for ${currentProject.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: currentProject.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () {
                    context.read<FoundProjectsData>().removeTagFromProject(currentProject, tag);
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Add new tag...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
