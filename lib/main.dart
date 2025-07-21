import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ue_launcher/models/found_engines_data.dart';
import 'package:window_manager/window_manager.dart';

import 'models/found_projects_data.dart';
import 'widgets/ue_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WindowOptions windowOptions = WindowOptions(
      minimumSize: Size(1280, 800),
      size: Size(1280, 800),
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await windowManager.show();
        await windowManager.focus();
      });
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FoundProjectsData()),
        ChangeNotifierProvider(create: (context) => FoundEnginesData()),
      ],
      child: UELauncher(),
    ),
  );
}
