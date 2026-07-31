import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_pckg;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_widgets/image_with_version_overlay.dart';
import '../models/cloning_provider.dart';
import '../models/found_projects_data.dart';
import '../models/unreal_project_data.dart';
import 'tag_editor_dialog.dart';

class ProjectGridItem extends StatefulWidget {
  final UnrealProjectData projectData;

  const ProjectGridItem({
    super.key,
    required this.projectData,
  });

  @override
  State<ProjectGridItem> createState() => _ProjectGridItemState();
}

class _ProjectGridItemState extends State<ProjectGridItem> {
  Future<void> openProject(BuildContext context, UnrealProjectData project) async {
    final Uri projectFileUri = Uri.file(project.path);

    if (await canLaunchUrl(projectFileUri)) {
      if (context.mounted) {
        Provider.of<FoundProjectsData>(context, listen: false).recordProjectLaunch(project);
      }
      await launchUrl(projectFileUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch ${project.path}'),
          ),
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
      } else {
        if (kDebugMode) {
          print('Could not open file explorer for $path');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file explorer for $path'),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opening directory: $path');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening directory: $path'),
          ),
        );
      }
    }
  }

  Future<void> _showCloneDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController(text: '${widget.projectData.name}_Clone');
    final String initialPath = File(widget.projectData.path).parent.parent.path;
    final TextEditingController pathController = TextEditingController(text: initialPath);
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Clone Project: ${widget.projectData.name}'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'New Project Name',
                        hintText: 'Enter name for the clone',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: pathController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Target Directory',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.folder_open),
                          onPressed: () async {
                            String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
                              initialDirectory: initialPath,
                            );
                            if (selectedDirectory != null) {
                              setDialogState(() {
                                pathController.text = selectedDirectory;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final newName = nameController.text.trim();
                      final targetPath = pathController.text.trim();
                      Navigator.pop(context); // Close dialog
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
    final projectsData = Provider.of<FoundProjectsData>(context, listen: false);

    cloningProvider.startClone(widget.projectData, newName, targetPath, projectsData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cloning "$newName" started in the background.')),
    );
  }

  void showContextMenu(BuildContext context, TapUpDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final cloningProvider = Provider.of<CloningProvider>(context, listen: false);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'open_in_explorer',
          child: Row(
            children: const [
              Icon(Icons.folder_open, size: 20),
              SizedBox(width: 8),
              Text('Open in File Explorer'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'clone',
          enabled: !cloningProvider.isCloning,
          child: Row(
            children: [
              const Icon(Icons.copy, size: 20),
              const SizedBox(width: 8),
              Text(cloningProvider.isCloning ? 'Cloning in progress...' : 'Clone Project'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'manage_tags',
          child: Row(
            children: const [
              Icon(Icons.label_outline, size: 20),
              SizedBox(width: 8),
              Text('Manage Tags'),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then<void>((String? selectedValue) {
      if (selectedValue == null) {
        return; // User dismissed the menu
      }

      if (selectedValue == 'open_in_explorer') {
        if (context.mounted) {
          openProjectInFileExplorer(context, widget.projectData.path);
        }
      } else if (selectedValue == 'clone') {
        if (context.mounted) {
          _showCloneDialog(context);
        }
      } else if (selectedValue == 'manage_tags') {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => TagEditorDialog(project: widget.projectData),
          );
        }
      }
    });
  }

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isHovered ? Theme.of(context).highlightColor : Theme.of(context).cardColor;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onDoubleTap: () {
          openProject(context, widget.projectData);
        },
        onSecondaryTapUp: (tapUpDetails) {
          showContextMenu(context, tapUpDetails);
        },
        child: Tooltip(
          message: widget.projectData.path,
          waitDuration: const Duration(milliseconds: 500),
          child: Card(
            color: cardColor,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (widget.projectData.thumbnailPath != null && widget.projectData.thumbnailPath!.isNotEmpty)
                    Expanded(
                      child: ImageWithVersionOverlay(
                        version: widget.projectData.engineVersion,
                        children: [
                          Image.file(
                            File(widget.projectData.thumbnailPath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 48);
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: ImageWithVersionOverlay(
                          version: widget.projectData.engineVersion,
                          children: [
                            Center(
                              child: Icon(
                                Icons.folder_zip,
                                size: 48,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.projectData.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.projectData.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        alignment: WrapAlignment.center,
                        children: widget.projectData.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                            ),
                          );
                        }).toList(),
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
