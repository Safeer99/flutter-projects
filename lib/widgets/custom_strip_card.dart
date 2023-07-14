import 'package:flutter/material.dart';

import '../constants.dart';

class CustomStripCard extends StatelessWidget {
  const CustomStripCard({super.key, required this.title, required this.number, required this.onTap, required this.totalQuestions});

  final int totalQuestions;
  final String title;
  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
            offset: const Offset(3, 3),
            blurRadius: 20,
            color: mainColor.withOpacity(0.2),
          )]
        ),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin:const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: card[number],
                  ),
                  child: Image.asset("assets/card${number + 1}.png", height: 50,)
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis, color: card[number]),),
                      const SizedBox(height: 4,),
                      Text("Questions: $totalQuestions", style: TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis, color: card[number]),),
                    ],
                  )
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}