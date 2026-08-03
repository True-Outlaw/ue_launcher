import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ue_launcher/features/engines/presentation/providers/engines_provider.dart';
import 'unreal_engine_display_item.dart';

class InstalledEngines extends StatefulWidget {
  const InstalledEngines({super.key});

  @override
  State<InstalledEngines> createState() => _InstalledEnginesState();
}

class _InstalledEnginesState extends State<InstalledEngines> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EnginesProvider>(context, listen: false).tryLoadDefaultOrSavedEngine();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnginesProvider>(
      builder: (context, enginesProvider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
                  child: Text(
                    'Engines',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => context.read<EnginesProvider>().manuallyAddEngine(),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<EnginesProvider>().tryLoadDefaultOrSavedEngine(),
                ),
              ],
            ),
            if (enginesProvider.latestAvailableVersion != null && enginesProvider.isUpdateAvailable)
              _buildUpdateBanner(context, enginesProvider),
            _buildEngineList(context, enginesProvider),
          ],
        );
      },
    );
  }

  Widget _buildUpdateBanner(BuildContext context, EnginesProvider data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          border: Border.all(color: Colors.amber),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'A newer version of Unreal Engine (${data.latestAvailableVersion}) is available!',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () => data.triggerEngineInstallation(data.latestAvailableVersion!),
              child: const Text('Install Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineList(BuildContext context, EnginesProvider data) {
    if (data.isLoading && data.foundEngines.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final int count = data.foundEngines.length;

    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        scrollDirection: Axis.horizontal,
        itemCount: count + 1,
        itemBuilder: (context, index) {
          if (index == count) {
            return const InstallNewEngineItem();
          }
          return UnrealEngineDisplayItem(engine: data.foundEngines[index]);
        },
      ),
    );
  }
}

class InstallNewEngineItem extends StatefulWidget {
  const InstallNewEngineItem({super.key});

  @override
  State<InstallNewEngineItem> createState() => _InstallNewEngineItemState();
}

class _InstallNewEngineItemState extends State<InstallNewEngineItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: () => context.read<EnginesProvider>().triggerEngineInstallation(''),
            child: Container(
              width: 240,
              height: 106,
              margin: const EdgeInsets.all(8.0),
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: _isHovered ? Colors.white : Colors.white54,
                  strokeWidth: 2,
                  borderRadius: 16,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: _isHovered ? Colors.white : Colors.white54,
                        size: 32,
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        'Install New',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _isHovered ? Colors.white : Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final ui.Path path = ui.Path()
      ..addRRect(
        RRect.fromLTRBR(
          strokeWidth / 2,
          strokeWidth / 2,
          size.width - strokeWidth / 2,
          size.height - strokeWidth / 2,
          Radius.circular(borderRadius),
        ),
      );

    const double dash = 10.0;
    const double gap = 5.0;

    for (final ui.PathMetric measure in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < measure.length) {
        final double length = draw ? dash : gap;
        if (draw) {
          canvas.drawPath(measure.extractPath(distance, distance + length), paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
