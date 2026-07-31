import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../models/found_projects_data.dart';

class ScannedFolders extends StatefulWidget {
  const ScannedFolders({super.key});

  @override
  State<ScannedFolders> createState() => _ScannedFoldersState();
}

class _ScannedFoldersState extends State<ScannedFolders> {
  @override
  Widget build(BuildContext context) {
    final projectsData = context.watch<FoundProjectsData>();
    final scannedFolders = projectsData.scannedFolders;
    final isScanning = projectsData.isScanning;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Folders',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (isScanning)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Rescan all folders',
                  onPressed: () {
                    context.read<FoundProjectsData>().rescanAllFolders();
                  },
                ),
            ],
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.all(8.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scannedFolders.length,
          itemBuilder: (context, index) {
            final folderPath = scannedFolders[index];
            final folderName = path.basename(folderPath);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      child: Text(
                        folderName,
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    tooltip: 'Rescan this folder',
                    onPressed: isScanning
                        ? null
                        : () {
                            context.read<FoundProjectsData>().rescanFolder(folderPath);
                          },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 16),
                    tooltip: 'Remove Folder',
                    onPressed: isScanning
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Remove Folder'),
                                  content: Text(
                                    'Are you sure you want to remove "$folderName" from the list? '
                                    'This will not delete the folder from your disk.',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Remove'),
                                      onPressed: () {
                                        Provider.of<FoundProjectsData>(
                                          context,
                                          listen: false,
                                        ).removeFoldersFromPath(scannedFolders[index]);
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              foregroundColor: Colors.white70,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: isScanning ? null : onScanButtonPressed,
            child: const Icon(Icons.add, size: 20),
          ),
        ),
      ],
    );
  }

  void onScanButtonPressed() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null && mounted) {
      final projectsData = Provider.of<FoundProjectsData>(context, listen: false);
      if (!projectsData.scannedFolders.contains(selectedDirectory)) {
        projectsData.scannedFolders.add(selectedDirectory);
        projectsData.rescanAllFolders();
      }
    }
  }
}
