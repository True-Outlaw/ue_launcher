import 'dart:io';

import 'package:flutter/material.dart';

import 'models/UnrealProjectData.dart';

class ProjectGridItem extends StatelessWidget {
  final UnrealProjectData projectData;

  const ProjectGridItem({
    super.key,
    required this.projectData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                child: Center(
                  child: Image.file(
                    File(projectData.thumbnailPath!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 48);
                    },
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Icon(Icons.folder_zip, size: 48, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 8.0),
            Text(
              projectData.name,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              'UE ${projectData.engineVersion}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
