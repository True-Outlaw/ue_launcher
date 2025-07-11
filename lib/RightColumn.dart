import 'package:flutter/material.dart';

class RightColumn extends StatelessWidget {
  const RightColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
        color: Colors.red,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text('Projects'),
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: Colors.pink,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.yellow,
                      child: Text('Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
