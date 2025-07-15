import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ProjectGridItem.dart';
import 'models/found_projects_data.dart';

class ProjectsWindow extends StatefulWidget {
  const ProjectsWindow({
    super.key,
  });

  @override
  State<ProjectsWindow> createState() => _ProjectsWindowState();
}

class _ProjectsWindowState extends State<ProjectsWindow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Projects',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sort by name',
                    padding: EdgeInsets.all(8.0),
                    icon: Icon(Icons.sort_by_alpha),
                    onPressed: () {
                      Provider.of<FoundProjectsData>(context, listen: false).sortProjectsByNameDescending();
                    },
                  ),
                  IconButton(
                    tooltip: 'Sort by date modified',
                    padding: EdgeInsets.all(8.0),
                    icon: Icon(Icons.date_range),
                    onPressed: () {
                      //TODO: implement sort by date modified
                      //Provider.of<FoundProjectsData>(context, listen: false).sortProjectsByNameDescending();
                    },
                  ),
                  IconButton(
                    tooltip: 'Sort by date modified',
                    padding: EdgeInsets.all(8.0),
                    icon: Icon(Icons.storage),
                    onPressed: () {
                      //TODO: implement sort by project size
                      //Provider.of<FoundProjectsData>(context, listen: false).sortProjectsByNameDescending();
                    },
                  ),
                ],
              ),
              Expanded(
                child: GridView.builder(
                  itemCount: Provider.of<FoundProjectsData>(context, listen: true).foundProjects.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ProjectGridItem(
                      projectData: Provider.of<FoundProjectsData>(context).foundProjects[index],
                    );
                  },
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Text(
              'Filters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ],
    );
  }
}
