import 'package:flutter/material.dart';

class RecentProjects extends StatelessWidget {
  const RecentProjects({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: SizedBox(
        //height: 400,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Recent Projects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
