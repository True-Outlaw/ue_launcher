import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as pathPckg;
import 'package:url_launcher/url_launcher.dart';

import 'custom_widgets/image_with_version_overlay.dart';
import 'models/UnrealProjectData.dart';

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
  Future<void> openProject(BuildContext context, String path) async {
    final Uri projectFileUri = Uri.file(path);

    if (await canLaunchUrl(projectFileUri)) {
      await launchUrl(projectFileUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $path'),
          ),
        );
      }
    }
  }

  Future<void> openProjectInFileExplorer(BuildContext context, String path) async {
    try {
      String directoryPath = pathPckg.dirname(path);
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

  void showContextMenu(BuildContext context, TapUpDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

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
        // You can add more options here
        // const PopupMenuDivider(),
        // const PopupMenuItem<String>(
        //   value: 'other_action',
        //   child: Text('Other Action'),
        // ),
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
      }
      // Handle other actions
      // else if (selectedValue == 'other_action') {
      //   print('Other action selected for ${projectData.name}');
      // }
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
          openProject(context, widget.projectData.path);
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
              borderRadius: BorderRadius.circular(0),
            ),
            margin: const EdgeInsets.all(8.0),
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
                          Center(
                            child: Image.file(
                              File(widget.projectData.thumbnailPath!),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 48);
                              },
                            ),
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
                            Icon(
                              Icons.folder_zip,
                              size: 48,
                              color: Colors.grey,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
