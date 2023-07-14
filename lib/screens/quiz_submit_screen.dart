import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/custom_number_box.dart';
import '../widgets/custom_button.dart';

class QuizSubmitScreen extends StatelessWidget {
  const QuizSubmitScreen({super.key, required this.questions, required this.answers, required this.setQuestion, required this.onPressed });

  final VoidCallback onPressed;
  final List questions;
  final Map<String, dynamic> answers;
  final Function setQuestion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        toolbarHeight: 80,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            splashRadius: 25,
            icon: const Icon(Icons.arrow_back),
        )
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 120),
                child: Wrap(
                  children:[
                    for(int i = 0; i < questions.length; i++)
                      CustomNumberBox(
                        number: i + 1, 
                        color: answers[questions[i]['id']] != null ? mainColor : Colors.white,
                        onTap: (){
                          setQuestion(i);
                          Navigator.pop(context);
                        }
                      )
                  ]
                ),
              ),
            ),
          ),
          const SizedBox(height: 110,),
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                height: 110,
                child: CustomButton(text: "Submit", onPressed: onPressed)
              )
            ),
          )
        ],
      ),
    );
  }
}

