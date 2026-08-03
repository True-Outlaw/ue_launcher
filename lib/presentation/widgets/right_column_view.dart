import 'package:flutter/material.dart';
import 'package:ue_launcher/features/engines/presentation/widgets/installed_engines_view.dart';
import 'package:ue_launcher/features/projects/presentation/widgets/projects_view.dart';

class RightColumn extends StatelessWidget {
  const RightColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
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
