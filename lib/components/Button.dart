import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final double BtnWidth;

  const CustomButton(
      {super.key,
        required this.text,
        required this.onPressed,
        required this.BtnWidth});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          )),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 118, 103, 183),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(horizontal: BtnWidth, vertical: 14),
      ),
    );
  }
}
