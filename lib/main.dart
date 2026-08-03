import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ue_launcher/core/di.dart';
import 'package:ue_launcher/features/engines/presentation/providers/engines_provider.dart';
import 'package:ue_launcher/features/projects/presentation/providers/cloning_provider.dart';
import 'package:ue_launcher/features/projects/presentation/providers/projects_provider.dart';
import 'package:ue_launcher/presentation/widgets/ue_launcher.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  DI.init();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WindowOptions windowOptions = const WindowOptions(
      minimumSize: Size(1280, 800),
      size: Size(1280, 800),
      center: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProjectsProvider()),
        ChangeNotifierProvider(create: (context) => EnginesProvider()),
        ChangeNotifierProvider(create: (context) => CloningProvider()),
      ],
      child: const UELauncher(),
    ),
  );
}
