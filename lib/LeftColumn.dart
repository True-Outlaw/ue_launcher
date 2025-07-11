import 'package:flutter/material.dart';

import 'CompanyLogo.dart';
import 'RecentProjects.dart';
import 'ScannedFolders.dart';

class LeftColumn extends StatelessWidget {
  const LeftColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CompanyLogo(),
          ScannedFolders(),
          RecentProjects(),
        ],
      ),
    );
  }
}
