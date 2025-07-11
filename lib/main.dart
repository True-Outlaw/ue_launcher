import 'package:flutter/material.dart';

import 'LeftColumn.dart';
import 'RightColumn.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: AppPage(),
      ),
    ),
  );
}

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LeftColumn(),
          RightColumn(),
        ],
      ),
    );
  }
}
