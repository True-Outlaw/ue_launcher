import 'package:flutter/material.dart';

import 'CompanyLogo.dart';
import 'RecentProjects.dart';
import 'ScannedFolders.dart';

class LeftColumn extends StatelessWidget {
  LeftColumn({super.key});

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
