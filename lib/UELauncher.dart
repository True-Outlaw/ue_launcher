import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'LeftColumn.dart';
import 'RightColumn.dart';
import 'models/found_projects_data.dart';

class UELauncher extends StatelessWidget {
  UELauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FoundProjectsData(),
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(),
        home: Scaffold(
          body: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                LeftColumn(),
                RightColumn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
