import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_pckg;
import 'package:provider/provider.dart';
import 'package:ue_launcher/core/widgets/image_with_version_overlay.dart';
import 'package:ue_launcher/features/projects/domain/entities/project.dart';
import 'package:ue_launcher/features/projects/presentation/providers/cloning_provider.dart';
import 'package:ue_launcher/features/projects/presentation/providers/projects_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'tag_editor_dialog.dart';

class ProjectGridItem extends StatefulWidget {
  final Project project;

  const ProjectGridItem({
    super.key,
    required this.project,
  });

  @override
  State<ProjectGridItem> createState() => _ProjectGridItemState();
}

class _ProjectGridItemState extends State<ProjectGridItem> {
  Future<void> openProject(BuildContext context, Project project) async {
    final Uri projectFileUri = Uri.file(project.path);
    if (await canLaunchUrl(projectFileUri)) {
      if (context.mounted) {
        Provider.of<ProjectsProvider>(context, listen: false).recordProjectLaunch(project);
      }
      await launchUrl(projectFileUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch ${project.path}')),
        );
      }
    }
  }

  Future<void> openProjectInFileExplorer(BuildContext context, String path) async {
    try {
      String directoryPath = path_pckg.dirname(path);
      final Uri fileExplorerUri = Uri.directory(directoryPath);
      if (await canLaunchUrl(fileExplorerUri)) {
        await launchUrl(fileExplorerUri);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file explorer for $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening directory: $path')),
        );
      }
    }
  }

  Future<void> _showCloneDialog(BuildContext context) async {
    final nameController = TextEditingController(text: '${widget.project.name}_Clone');
    final initialPath = File(widget.project.path).parent.parent.path;
    final pathController = TextEditingController(text: initialPath);
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Clone Project: ${widget.project.name}'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'New Project Name'),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: pathController,
                            readOnly: true,
                            decoration: const InputDecoration(labelText: 'Target Directory'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.folder_open),
                          onPressed: () async {
                            String? selected = await FilePicker.platform.getDirectoryPath(
                              initialDirectory: initialPath,
                            );
                            if (selected != null) setDialogState(() => pathController.text = selected);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final newName = nameController.text.trim();
                      final targetPath = pathController.text.trim();
                      Navigator.pop(context);
                      await _performClone(context, newName, targetPath);
                    }
                  },
                  child: const Text('Clone'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _performClone(BuildContext context, String newName, String targetPath) async {
    final cloningProvider = Provider.of<CloningProvider>(context, listen: false);
    final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
    cloningProvider.startClone(widget.project, newName, targetPath, projectsProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cloning "$newName" started.')));
  }

  void showContextMenu(BuildContext context, TapUpDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final cloningProvider = Provider.of<CloningProvider>(context, listen: false);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(details.globalPosition & const Size(40, 40), Offset.zero & overlay.size),
      items: [
        const PopupMenuItem(
          value: 'open_in_explorer',
          child: Row(children: [Icon(Icons.folder_open, size: 20), SizedBox(width: 8), Text('Open in File Explorer')]),
        ),
        PopupMenuItem(
          value: 'clone',
          enabled: !cloningProvider.isCloning,
          child: Row(
            children: [
              const Icon(Icons.copy, size: 20),
              const SizedBox(width: 8),
              Text(cloningProvider.isCloning ? 'Cloning...' : 'Clone Project'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'manage_tags',
          child: Row(children: [Icon(Icons.label_outline, size: 20), SizedBox(width: 8), Text('Manage Tags')]),
        ),
      ],
    ).then((selectedValue) {
      if (!context.mounted || selectedValue == null) return;

      if (selectedValue == 'open_in_explorer') {
        openProjectInFileExplorer(context, widget.project.path);
      } else if (selectedValue == 'clone') {
        _showCloneDialog(context);
      } else if (selectedValue == 'manage_tags') {
        showDialog(
          context: context,
          builder: (context) => TagEditorDialog(project: widget.project),
        );
      }
    });
  }

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onDoubleTap: () => openProject(context, widget.project),
        onSecondaryTapUp: (details) => showContextMenu(context, details),
        child: Tooltip(
          message: widget.project.path,
          child: Card(
            color: isHovered ? Theme.of(context).highlightColor : Theme.of(context).cardColor,
            elevation: 8.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ImageWithVersionOverlay(
                      version: widget.project.engineVersion,
                      children: [
                        if (widget.project.thumbnailPath != null)
                          Image.file(
                            File(widget.project.thumbnailPath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 48),
                          )
                        else
                          Icon(Icons.folder_zip, size: 48, color: Theme.of(context).hintColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.project.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.project.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        alignment: WrapAlignment.center,
                        children: widget.project.tags
                            .take(3)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(tag, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
