import 'package:flutter/material.dart';

class ImageWithVersionOverlay extends StatelessWidget {
  final String version;
  final List<Widget> children;

  const ImageWithVersionOverlay({
    super.key,
    required this.version,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ...children,
        Container(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.all(4.0),
            color: Colors.black,
            child: Text(
              'UE $version',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
