import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cloning_provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CloningProvider>(
      builder: (context, cloningProvider, child) {
        if (!cloningProvider.isCloning) {
          return Container(
            height: 24,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Row(
              children: [
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Ready', style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          );
        }

        return Container(
          height: 24,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Cloning ${cloningProvider.currentProjectName}: ${cloningProvider.statusMessage}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              SizedBox(
                width: 100,
                height: 4,
                child: LinearProgressIndicator(
                  value: cloningProvider.progress,
                  backgroundColor: Colors.white24,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        );
      },
    );
  }
}
