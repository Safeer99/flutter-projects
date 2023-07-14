import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/provider/auth_provider.dart';
import 'package:quiz_app/provider/result_provider.dart';
import 'package:quiz_app/screens/home_screen.dart';
import '../constants.dart';
import 'package:confetti/confetti.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {

  final controller = ConfettiController();

  @override
  void initState() {
    super.initState();
    final result = Provider.of<ResultsProvider>(context, listen: false).getResult;
    if(result.correctAnswers < result.totalQuestions / 2){
      controller.stop();
    }else{
      controller.play();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final ap = Provider.of<AuthProvider>(context, listen: false);
    final result = Provider.of<ResultsProvider>(context, listen: false).getResult;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: mainColor,
        body: Center(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 50, top: 100),
                child: Column(
                  children: [
                    const Text("Quiz Result", style: TextStyle(fontSize: 25,color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 40),
                    Stack(
                      children:<Widget>[
                        Image.asset("assets/trophy.png"),
                        Positioned(
                          top: 15,
                          left: 0,
                          right: 0,
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: mainColor,
                              border: Border.all(width: 2, color: Colors.white),
                              boxShadow: [BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color:Colors.black.withOpacity(0.1)
                              )],
                              shape: BoxShape.circle,
                              image:  ap.userModel.profilePic != "" ? DecorationImage(
                                fit: BoxFit.contain,
                                image: NetworkImage(ap.userModel.profilePic),
                              ) : null,
                            ),
                            child: ap.userModel.profilePic == "" ? const Icon(Icons.account_circle, size: 51, color: Colors.white,) : null,
                          ),
                        )
                      ]
                    ),
                    const SizedBox(height: 30,),
                    Text(
                      result.correctAnswers < result.totalQuestions / 2 ? "Better Luck Next Time!" : "Congratulations!", 
                      style: const TextStyle(fontSize: 30,color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 15,),
                    Text(
                      result.correctAnswers < result.totalQuestions / 2 
                        ? "In defeat, lies an opportunity for growth and a stronger comeback in the quiz game"
                        : "Knowledge triumphs, paving the path to victory in the quiz game.",
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 35,),
                    const Text("YOUR SCORE", style: TextStyle(fontSize: 18,wordSpacing: 5,color: Colors.white, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20,),
                    Text("${result.correctAnswers} / ${result.totalQuestions}", style: const TextStyle(fontSize: 28,color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20,),
                    Text("Attempted: ${result.answers.length}", style: const TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 100),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.pushReplacement(context, 
                            MaterialPageRoute(builder: (context) => const HomeScreen())
                          );
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(mainColor),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)
                            ),
                          ),
                        ),
                        child: const Text("Take another quiz", style: TextStyle(fontSize: 16) ),
                      )
                    )
                  ]
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                      confettiController: controller,
                      shouldLoop: true,
                      blastDirectionality: BlastDirectionality.explosive
                    ),  
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (context) => const HomeScreen())
        );
        return false;
      },
    );
  }
}