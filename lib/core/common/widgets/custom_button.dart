import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;

  const CustomButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: const Color(0xff011C2A),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 48),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
