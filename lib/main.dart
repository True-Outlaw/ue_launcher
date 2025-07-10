import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 30,
                        child: Image(
                          image: AssetImage('images/True-Outlaw-Logo.png'),
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        color: Colors.blue,
                        height: 400,
                        child: Text('Folders'),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        color: Colors.green,
                        height: 400,
                        child: Text('Recent Projects'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
