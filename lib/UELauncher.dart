import 'package:flutter/material.dart';

import 'LeftColumn.dart';
import 'RightColumn.dart';

class UELauncher extends StatelessWidget {
  UELauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(),
      home: Scaffold(
        body: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: LeftColumn(),
              ),
              Expanded(
                flex: 4,
                child: RightColumn(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
