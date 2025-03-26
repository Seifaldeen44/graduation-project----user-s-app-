import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  final double size;

  const CustomLogo({
    super.key,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.transparent,
        child: Image.asset("images/download.jpg"),
      ),
    );
  }
}
