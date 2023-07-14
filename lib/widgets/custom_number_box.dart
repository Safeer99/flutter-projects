import 'package:flutter/material.dart';
import '../constants.dart';

class CustomNumberBox extends StatelessWidget {
  const CustomNumberBox({super.key, required this.number, required this.onTap, required this.color});

  final int number;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: mainColor),
        borderRadius: BorderRadius.circular(10)
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(number.toString(), style: TextStyle(fontSize: 20, color: color != Colors.white ? Colors.white : mainColor),)
        ),
      ),
    );
  }
}