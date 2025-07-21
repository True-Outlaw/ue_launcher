import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/found_engines_data.dart';
import '../models/unreal_engine_info.dart';

class UnrealEngineDisplayItem extends StatefulWidget {
  final UnrealEngineInfo engineInfo;

  const UnrealEngineDisplayItem({
    super.key,
    required this.engineInfo,
  });

  @override
  State<UnrealEngineDisplayItem> createState() => _UnrealEngineDisplayItemState();
}

class _UnrealEngineDisplayItemState extends State<UnrealEngineDisplayItem> {
  Future<void> openEngine(BuildContext context, String path) async {
    final Uri engineUri = Uri.file(path);

    if (await canLaunchUrl(engineUri)) {
      await launchUrl(engineUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $path'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
          ),
          child: Row(
            children: [
              Image.asset(
                'images/UE-Icon-2023-White.png',
                alignment: Alignment.centerLeft,
              ),
              SizedBox(
                width: 8.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.engineInfo.version,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  ElevatedButton(
                    child: Text('Launch'),
                    onPressed: () {
                      openEngine(context, widget.engineInfo.executablePath);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        RemoveEngineDisplayItem(widget: widget),
      ],
    );
  }
}

class RemoveEngineDisplayItem extends StatelessWidget {
  const RemoveEngineDisplayItem({
    super.key,
    required this.widget,
  });

  final UnrealEngineDisplayItem widget;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
            ),
            tooltip: 'Remove Engine',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: const Text('Confirm Removal'),
                    content: Text(
                      'Are you sure you want to remove Unreal Engine ${widget.engineInfo.version} from the list?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Remove'),
                        onPressed: () {
                          Provider.of<FoundEnginesData>(context, listen: false).removeEngine(widget.engineInfo);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
