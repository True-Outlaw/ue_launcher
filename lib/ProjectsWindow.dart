import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return Expanded(
      flex: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: TabBar(
                  tabs: [
                    Tab(child: Text('All')),
                    Tab(child: Text('Favourites')),
                  ],
                ),
                body: TabBarView(
                  children: [
                    GridView.builder(
                      itemCount: Provider.of<FoundProjectsData>(context).foundProjects.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Image.asset('images/True-Outlaw-Logo.png');
                      },
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                      ),
                    ),
                    Text('Favourites'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Text('Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
