import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ue_launcher/features/projects/domain/entities/project.dart';
import 'package:ue_launcher/features/projects/presentation/providers/projects_provider.dart';

class RecentProjects extends StatelessWidget {
  const RecentProjects({
    super.key,
  });

  Future<void> openProject(BuildContext context, Project project) async {
    final Uri projectFileUri = Uri.file(project.path);
    if (await canLaunchUrl(projectFileUri)) {
      if (context.mounted) {
        Provider.of<ProjectsProvider>(context, listen: false).recordProjectLaunch(project);
      }
      await launchUrl(projectFileUri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch ${project.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsProvider = context.watch<ProjectsProvider>();
    final recentPaths = projectsProvider.recentProjectPaths;
    final allProjects = projectsProvider.foundProjects;

    final recentProjects = recentPaths.map((path) {
      return allProjects.firstWhere(
        (p) => p.path == path,
        orElse: () => Project(
          path: path,
          name: 'Unknown Project',
          engineVersion: '?',
          created: DateTime.now(),
          modified: DateTime.now(),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Recent Projects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (recentProjects.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No recently opened projects.'),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: recentProjects.length,
              itemBuilder: (context, index) {
                final project = recentProjects[index];
                return ListTile(
                  dense: true,
                  leading: project.thumbnailPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(project.thumbnailPath!),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.folder),
                          ),
                        )
                      : const Icon(Icons.folder),
                  title: Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    project.engineVersion,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () => openProject(context, project),
                );
              },
            ),
          ),
      ],
    );
  }
}
