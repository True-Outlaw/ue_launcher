import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ue_launcher/models/found_engines_data.dart';
import 'package:window_manager/window_manager.dart';

import 'UELauncher.dart';
import 'models/found_projects_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WindowOptions windowOptions = WindowOptions(
      minimumSize: Size(800, 800),
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
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
