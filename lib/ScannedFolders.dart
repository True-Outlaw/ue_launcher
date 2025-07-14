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
  bool isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Folders'),
            ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount: scannedFolders.length,
                itemBuilder: (context, index) {
                  final folderPath = scannedFolders[index];
                  final folderName = path.basename(folderPath);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                            child: Text(folderName),
                            onPressed: () {},
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          tooltip: 'Remove Folder',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: Text('Remove Folder'),
                                  content: Text(
                                    'Are you sure you want to remove "$folderName" from the list? '
                                    'This will not delete the folder from your disk.',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Remove'),
                                      onPressed: () {
                                        setState(() {
                                          scannedFolders.removeAt(index);
                                        });

                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: isScanning ? null : onScanButtonPressed,
                child: isScanning
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onScanButtonPressed() async {
    setState(() {
      isScanning = true;
    });

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null && !scannedFolders.contains(selectedDirectory)) {
      List<UnrealProjectData> foundProjects = await scanForUProjects(selectedDirectory);

      setState(() {
        if (!scannedFolders.contains(selectedDirectory)) {
          scannedFolders.add(selectedDirectory);
        }
        // You might want to do something with foundProjects here,
        // like adding them to another list to display project details.
        if (kDebugMode) {
          print('Scan complete. Found ${foundProjects.length} projects.');
        }
      });
    }

    setState(() {
      isScanning = false; // Stop scanning, update UI
    });
  }
}

Future<List<UnrealProjectData>> scanForUProjects(String folder) async {
  final projects = <UnrealProjectData>[];
  final Set<String> visitedFolders = {}; // Keep track of visited folders to avoid redundant scans

  Future<void> scanDirectory(Directory directory) async {
    if (visitedFolders.contains(directory.path)) {
      return; // Already processed this folder
    }
    visitedFolders.add(directory.path);

    try {
      final List<FileSystemEntity> entities = await directory.list().toList();
      bool uprojectFoundInCurrentDir = false;

      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.uproject')) {
          final proj = await UnrealProjectData.fromFile(entity);
          if (proj != null) {
            projects.add(proj);
            uprojectFoundInCurrentDir = true;
            if (kDebugMode) {
              print('Found project: ${proj.name} in ${entity.path}');
            }
          }
        }
      }

      // If a .uproject file was found in the current directory,
      // don't scan its subdirectories.
      if (uprojectFoundInCurrentDir) {
        return;
      }

      // If no .uproject file was found, recursively scan subdirectories
      for (final entity in entities) {
        if (entity is Directory) {
          // Check if the subdirectory might contain a project
          // (e.g., by looking for common Unreal Engine folder names or just proceed)
          // For simplicity, this example will scan all subdirectories
          // if no .uproject is found at the current level.
          await scanDirectory(entity);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scanning directory ${directory.path}: $e');
      }
      // Handle errors, e.g., permission issues
    }
  }

  await scanDirectory(Directory(folder));
  return projects;
}
