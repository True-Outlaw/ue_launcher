import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ue_launcher/widgets/projects_header_sort_view.dart';

import '../models/found_projects_data.dart';
import 'filter_column_view.dart';
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
      Provider.of<FoundProjectsData>(context, listen: false).loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Column(
            children: [
              ProjectsHeaderAndSort(),
              Expanded(
                child: GridView.builder(
                  itemCount: Provider.of<FoundProjectsData>(context, listen: true).foundProjects.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ProjectGridItem(
                      projectData: Provider.of<FoundProjectsData>(context).foundProjects[index],
                    );
                  },
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: FilterColumn(),
        ),
      ],
    );
  }
}
