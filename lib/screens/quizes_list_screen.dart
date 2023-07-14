import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/quiz_model.dart';
import 'package:quiz_app/provider/quizes_provider.dart';
import 'package:quiz_app/screens/quiz_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_page_route.dart';
import '../constants.dart';
import '../widgets/custom_strip_card.dart';

class QuizesListScreen extends StatelessWidget {
  const QuizesListScreen({super.key, required this.isRecommendedList});

  final bool isRecommendedList;

  @override
  Widget build(BuildContext context) {

    final qp = Provider.of<QuizesProvider>(context, listen: false);
    List<Quiz> quizes = isRecommendedList ? qp.getRecommendedQuizes : qp.getQuizes;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: mainColor,
        title: Text(isRecommendedList ? "Recommended" : qp.getSelectedCategory),
        centerTitle: true,
      ),
      body: Padding(
        padding:const EdgeInsets.all(8),
        child: ListView(
          children: [
            for(int i = 0; i < quizes.length; i++)
              CustomStripCard(title: quizes[i].title, number: i%3, totalQuestions: quizes[i].totalQuestions,
                onTap: (){
                  showDialog(context: context, 
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Column(
                          children: [
                            Text("Quiz: ${quizes[i].title}", textAlign: TextAlign.center),
                            const SizedBox(height: 10,),
                            Text("Questions: ${quizes[i].totalQuestions}", style: const TextStyle(fontSize: 14, color: Colors.black38), textAlign: TextAlign.center),
                            const SizedBox(height: 0,),
                          ],
                        ),
                        actions: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 40,
                                child: CustomButton(text: "Cancel", onPressed: (){
                                  Navigator.pop(context);
                                }),
                              ),
                              SizedBox(
                                width: 100,
                                height: 40,
                                child: CustomButton(text: "START", onPressed: (){
                                  qp.setQuiz(i, false);
                                  Navigator.push(context, 
                                    CustomPageRoute(child: const QuizScreen(), direction: AxisDirection.right)
                                  );
                                }),
                              ),
                          ],),
                        )
                      ],);
                    }
                  );
              })
          ],
        ),
      ),
    );
  }
}
