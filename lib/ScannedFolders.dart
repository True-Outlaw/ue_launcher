import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'UnrealProjectData.dart';

class ScannedFolders extends StatefulWidget {
  const ScannedFolders({
    super.key,
  });

  @override
  State<ScannedFolders> createState() => _ScannedFoldersState();
}

class _ScannedFoldersState extends State<ScannedFolders> {
  List<String> scannedFolders = [];

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        color: Colors.blue,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Folders'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8.0,
                children: <Widget>[
                  ...scannedFolders.map(
                    (folder) => TextButton(
                      onPressed: () {},
                      child: Text(path.basename(folder)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory != null && !scannedFolders.contains(selectedDirectory)) {
                        setState(() {
                          scannedFolders.add(selectedDirectory);
                        });

                        scanForUProjects(selectedDirectory);
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void scanForUProjects(String folder) async {
  final dir = Directory(folder);
  final files = await dir.list(recursive: true).toList();
  final uprojectFiles = files.where((f) => f.path.endsWith('.uproject')).cast<File>();

  List<UnrealProjectData> projects = [];

  for (final file in uprojectFiles) {
    final proj = await UnrealProjectData.fromFile(file);
    if (proj != null) {
      projects.add(proj);

      if (kDebugMode) {
        print('Found project: ${proj.name}');
      }
    }
  }
}
