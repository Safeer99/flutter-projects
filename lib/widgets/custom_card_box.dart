import 'package:flutter/material.dart';
import '../constants.dart';

class CustomCardBox extends StatelessWidget {
  const CustomCardBox({super.key, required this.title, required this.number, required this.onTap});

  final String title;
  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.only(top: 10,left: 15, bottom: 0, right: 10),
      width: (size.width/2 - 36) < 130 ? double.infinity : (size.width/2 - 36),
      height: 150,
      decoration: BoxDecoration(
        color: card[number],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
          offset: const Offset(0, 5),
          blurRadius: 30,
          color: mainColor.withOpacity(0.3),
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
              child: Image.asset('assets/card${number+1}.png', height: 80)
            ),
        ]),
      ),
    );
  }
}