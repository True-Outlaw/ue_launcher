import 'package:flutter/material.dart';

class RecentProjects extends StatelessWidget {
  const RecentProjects({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        height: 400,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Recent Projects'),
        ),
      ),
    );
  }
}
