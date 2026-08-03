import 'package:flutter/material.dart';
import 'package:ue_launcher/core/widgets/company_logo_view.dart';
import 'package:ue_launcher/features/projects/presentation/widgets/recent_projects_view.dart';
import 'package:ue_launcher/features/projects/presentation/widgets/scanned_folders_view.dart';
import 'status_bar_view.dart';

class LeftColumn extends StatelessWidget {
  const LeftColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CompanyLogo(),
        ScannedFolders(),
        Expanded(child: RecentProjects()),
        StatusBar(),
      ],
    );
  }
}
