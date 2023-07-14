import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/quiz_model.dart';
import 'package:quiz_app/provider/admin_control_provider.dart';
import 'package:quiz_app/widgets/custom_page_route.dart';
import './quiz_detail_screen.dart';
import '../../widgets/custom_strip_card.dart';
import '../../constants.dart';

class QuizesScreen extends StatelessWidget {
  const QuizesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final up = Provider.of<AdminControlProvider>(context, listen: true);
    final List<Quiz> quizList = up.getQuizesList;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text("Quizes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            for(int i = 0; i < quizList.length; i++)
              CustomStripCard(title: quizList[i].title, number: i%3, totalQuestions: quizList[i].totalQuestions, onTap: (){
                Navigator.push(context, 
                  CustomPageRoute(child: QuizDetailsScreen(quiz: quizList[i]), direction: AxisDirection.left),
                );
              },)
          ],
        ),
      )
    );
  }
}