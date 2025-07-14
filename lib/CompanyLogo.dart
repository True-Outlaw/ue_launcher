import 'package:flutter/material.dart';

class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: CircleAvatar(
        radius: 30,
        child: Image.asset('images/True-Outlaw-Logo.png'),
      ),
    );
  }
}
