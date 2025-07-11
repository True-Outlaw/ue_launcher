import 'package:flutter/material.dart';

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
            child: Container(
              color: Colors.pink,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.yellow,
              child: Text('Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
