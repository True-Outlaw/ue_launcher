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
              return GridView.builder(
                itemCount: projectsProvider.filteredProjects.length,
                itemBuilder: (BuildContext context, int index) {
                  return ProjectGridItem(
                    project: projectsProvider.filteredProjects[index],
                  );
                },
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
