import 'package:flutter/material.dart';

import 'company_logo_view.dart';
import 'recent_projects_view.dart';
import 'scanned_folders_view.dart';

class LeftColumn extends StatelessWidget {
  const LeftColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CompanyLogo(),
        ScannedFolders(),
        RecentProjects(),
      ],
    );
  }
}
