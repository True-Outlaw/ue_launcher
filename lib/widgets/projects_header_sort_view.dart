import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/found_projects_data.dart';

class ProjectsHeaderAndSort extends StatelessWidget {
  const ProjectsHeaderAndSort({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
            Provider.of<FoundProjectsData>(context, listen: false).sortProjectsByName();
          },
        ),
        IconButton(
          tooltip: 'Sort by date created',
          padding: EdgeInsets.all(8.0),
          icon: Icon(Icons.create_new_folder),
          onPressed: () {
            Provider.of<FoundProjectsData>(context, listen: false).sortProjectsByDateCreated();
          },
        ),
        IconButton(
          tooltip: 'Sort by date modified',
          padding: EdgeInsets.all(8.0),
          icon: Icon(Icons.edit_calendar),
          onPressed: () {
            Provider.of<FoundProjectsData>(context, listen: false).sortProjectsByDateModified();
          },
        ),
        IconButton(
          tooltip: 'Sort by engine version',
          padding: EdgeInsets.all(8.0),
          icon: Icon(Icons.numbers),
          onPressed: () {
            Provider.of<FoundProjectsData>(context, listen: false).sortProjectsByEngineVersion();
          },
        ),
      ],
    );
  }
}
