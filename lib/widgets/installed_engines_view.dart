import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ue_launcher/models/found_engines_data.dart';

import 'unreal_engine_display_item.dart';

class InstalledEngines extends StatefulWidget {
  const InstalledEngines({
    super.key,
  });

  @override
  State<InstalledEngines> createState() => _InstalledEnginesState();
}

class _InstalledEnginesState extends State<InstalledEngines> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoundEnginesData>(context, listen: false).tryLoadDefaultOrSavedEngine();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoundEnginesData>(
      builder: (context, foundEnginesData, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Engines',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    padding: EdgeInsets.all(8.0),
                    onPressed: () {
                      Provider.of<FoundEnginesData>(context, listen: false).manuallyAddEngine();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(Icons.refresh),
                    padding: EdgeInsets.all(8.0),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            if (foundEnginesData.isLoading && foundEnginesData.foundEngines.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (foundEnginesData.foundEngines.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No Unreal Engine installations configured.\nClick + to add one.'),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: foundEnginesData.foundEngines.length,
                  itemBuilder: (context, index) {
                    final engine = foundEnginesData.foundEngines[index];
                    return UnrealEngineDisplayItem(engineInfo: engine);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
