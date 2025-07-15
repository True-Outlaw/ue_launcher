import 'package:flutter/material.dart';

import 'ProjectsWindow.dart';

class RightColumn extends StatelessWidget {
  const RightColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Projects',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            ProjectsWindow(),
          ],
        ),
      ),
    );
  }
}
