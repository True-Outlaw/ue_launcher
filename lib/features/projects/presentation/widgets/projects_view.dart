import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ue_launcher/features/projects/presentation/providers/projects_provider.dart';
import 'projects_header_sort_view.dart';
import 'project_grid_item.dart';

class ProjectsWindow extends StatefulWidget {
  const ProjectsWindow({
    super.key,
  });

  @override
  State<ProjectsWindow> createState() => _ProjectsWindowState();
}

class _ProjectsWindowState extends State<ProjectsWindow> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectsProvider>(context, listen: false).loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProjectsHeaderAndSort(),
        Expanded(
          child: Consumer<ProjectsProvider>(
            builder: (context, projectsProvider, child) {
              if (projectsProvider.isScanning && projectsProvider.foundProjects.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Scanning for Unreal Engine projects...'),
                    ],
                  ),
                );
              }

              if (projectsProvider.foundProjects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open_outlined, size: 64, color: Theme.of(context).hintColor),
                      const SizedBox(height: 16),
                      Text(
                        'No Unreal Engine projects found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add a directory to the Folders list on the left to scan for projects.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              if (projectsProvider.filteredProjects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Theme.of(context).hintColor),
                      const SizedBox(height: 16),
                      Text(
                        'No projects match your search or filter',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          projectsProvider.cancelSearch();
                          projectsProvider.selectedTags.clear();
                          projectsProvider.sortProjectsByDateModified();
                        },
                        child: const Text('Reset Filters'),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: projectsProvider.filteredProjects.length,
                itemBuilder: (BuildContext context, int index) {
                  return ProjectGridItem(
                    project: projectsProvider.filteredProjects[index],
                  );
                },
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  childAspectRatio: 0.88,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
