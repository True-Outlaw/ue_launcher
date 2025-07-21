import 'package:flutter/material.dart';

import 'installed_engines_view.dart';
import 'projects_view.dart';

class RightColumn extends StatelessWidget {
  const RightColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InstalledEngines(),
        Expanded(
          flex: 3,
          child: ProjectsWindow(),
        ),
      ],
    );
  }
}
