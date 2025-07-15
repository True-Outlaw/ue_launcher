import 'package:flutter/material.dart';

import 'ProjectsWindow.dart';

class RightColumn extends StatelessWidget {
  const RightColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Engines',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: ProjectsWindow(),
        ),
      ],
    );
  }
}
