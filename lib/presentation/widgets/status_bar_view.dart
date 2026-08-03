import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ue_launcher/features/projects/presentation/providers/cloning_provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CloningProvider>(
      builder: (context, cloningProvider, child) {
        if (!cloningProvider.isCloning) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            alignment: Alignment.bottomRight,
            child: const Text(
              'Ready',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Cloning ${cloningProvider.currentProjectName}: ${cloningProvider.statusMessage}',
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 2,
                child: LinearProgressIndicator(
                  value: cloningProvider.progress,
                  backgroundColor: Colors.white10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
