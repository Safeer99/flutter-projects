import 'package:flutter/material.dart';
import '../constants.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key, required this.title, required this.number, required this.onTap});

  final String title;
  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 40, left: 27),
      padding: const EdgeInsets.only(top: 10,left: 15, bottom: 0, right: 10),
      width: 210,
      height: 120,
      decoration: BoxDecoration(
        color: card[number - 1],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
          offset: const Offset(0, 5),
          blurRadius: 30,
          color: card[number - 1].withOpacity(0.23),
        )]
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(children: <Widget> [
            Text(
              title,
              maxLines: title.split(" ").length > 1 ? 2 : 1,
              softWrap: true,
              style: const TextStyle(overflow: TextOverflow.ellipsis,color: Colors.white,fontSize: 22)
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset('assets/card$number.png', height: 90)
            ),
        ]),
      ),
    );
  }
}