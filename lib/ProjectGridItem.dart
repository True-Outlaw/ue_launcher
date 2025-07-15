import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'custom_widgets/image_with_version_overlay.dart';
import 'models/UnrealProjectData.dart';

class ProjectGridItem extends StatelessWidget {
  final UnrealProjectData projectData;

  const ProjectGridItem({
    super.key,
    required this.projectData,
  });

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        openProject(context, projectData.path);
      },
      child: Tooltip(
        message: projectData.path,
        waitDuration: const Duration(milliseconds: 500),
        child: Card(
          elevation: 4.0,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (projectData.thumbnailPath != null && projectData.thumbnailPath!.isNotEmpty)
                  Expanded(
                    child: ImageWithVersionOverlay(
                      version: projectData.engineVersion,
                      children: [
                        Center(
                          child: Image.file(
                            File(projectData.thumbnailPath!),
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
                  const Expanded(
                    child: Center(
                      child: Icon(Icons.folder_zip, size: 48, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16.0),
                Text(
                  projectData.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
