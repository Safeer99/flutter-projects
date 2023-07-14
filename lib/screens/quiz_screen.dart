import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/quiz_model.dart';
import 'package:quiz_app/models/result_model.dart';
import 'package:quiz_app/provider/auth_provider.dart';
import 'package:quiz_app/provider/quizes_provider.dart';
import 'package:quiz_app/provider/result_provider.dart';
import 'package:quiz_app/screens/home_screen.dart';
import 'package:quiz_app/screens/quiz_result_screen.dart';
import '../constants.dart';
import '../widgets/custom_button.dart';
import 'dart:async';
import './quiz_submit_screen.dart';
import '../widgets/custom_page_route.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  final Map<String, dynamic>? answers = {};
  Quiz? quiz;
  int _index = 0;

  Timer? _timer;
  int _start = 0;

  //! TIMER
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            calculateResult();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  //! set time format from seconds to hh:mm:ss
  String setTimeFormat(time){
    String seconds = "00", minutes = "00", hours = "00";
    int sec = (time % 60).toInt();
    int min = time ~/ 60;

    if(min > 59){
      int hr = min ~/ 60;
      min = min % 60;
      hours = hr < 10 ? "0$hr" : hr.toString();
    }
    seconds = sec < 10 ? "0$sec" : sec.toString();
    minutes = min < 10 ? "0$min" : min.toString();
    
    if(hours != "00") return "$hours:$minutes:$seconds";
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    setState((){
      quiz = Provider.of<QuizesProvider>(context, listen: false).getSelectedQuiz;
      _start = quiz!.time;
    });
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String questionId = quiz!.questions[_index]['id'];
    String question = quiz!.questions[_index]['question'];
    List options = quiz!.questions[_index]['options'];
    String correctAnswer = quiz!.questions[_index]['correctOption'];
    Size size = MediaQuery.of(context).size;
    
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: mainColor,
          leadingWidth: 100,
          //! timer
          leading: Center(
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(setTimeFormat(_start), style:const TextStyle(fontSize: 15),)
            ),
          ),
          //! title
          centerTitle: true,
          title: SizedBox(
            width: size.width - 200,
            child: Text(quiz!.title.toUpperCase(),textAlign: TextAlign.center, maxLines: 2, softWrap: true,)
          ),
          //! questions screen redirect
          actions: [
            IconButton(
              padding: const EdgeInsets.only(left: 48, right: 28),
              onPressed: (){
                Navigator.push(context, 
                  CustomPageRoute(child: QuizSubmitScreen(
                      questions: quiz!.questions,
                      answers: answers!,
                      setQuestion: (n) {
                        setState(() { 
                          _index = n; 
                        });
                      },
                      onPressed: () {
                        calculateResult();
                      }
                    ),
                    direction: AxisDirection.left
                  )
                );
              }, 
              splashRadius: 25,
              icon: const Icon(Icons.apps, size: 30,)
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 40),
          child: Column(
            children: [
              //! question number and total questions
              Row(children: [
                Text("Question ${_index+1}", style:const TextStyle(fontSize: 25,color: mainColor, fontWeight: FontWeight.bold),),
                Text("/${quiz!.totalQuestions.toString()}", style: const TextStyle(fontSize: 15, color: mainColor),),
              ],),
              //! questions attempted progress bar
              Container(
                margin:const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(1),
                width: double.infinity,
                height: 20,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  border: Border.all(color: mainColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child:ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    value: (answers!.length.toDouble() / quiz!.totalQuestions.toDouble()), 
                    valueColor: const AlwaysStoppedAnimation<Color>(mainColor),
                  ),
                )
              ),
              //! question card with options
              Container(
                width: double.infinity,
                height: size.height * 0.55,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                    offset: const Offset(0, 5),
                    blurRadius: 30,
                    color: mainColor.withOpacity(0.23),
                  )]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //! question
                    Text(question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                    const Spacer(),
                    //! options
                    for(int i = 0; i < options.length; i++)
                        OptionButton(
                          option: options[i],
                          attempted: answers![questionId]?["selectedOption"] != options[i] ? false : true,
                          onTap: (){
                            setState(() {
                              answers?[questionId] = {
                                "selectedOption": options[i], 
                                "correctOption": correctAnswer,
                              };
                            });
                          } 
                        )
                ]),
              ),
              const Spacer(),
              //! button for next question or submit the quiz
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _index + 1 < quiz!.totalQuestions
                  ? CustomButton(text: "Next", onPressed: (){
                    setState(() { 
                      _index++; 
                    });
                  },)
                  : CustomButton(text: "Finish", onPressed: (){
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => 
                          QuizSubmitScreen(
                            questions: quiz!.questions,
                            answers: answers!,
                            setQuestion: (n) {
                              setState(() { 
                                _index = n; 
                              });
                            },
                            onPressed: (){
                              calculateResult();
                            }
                          )
                        )
                      );
                  },)
              )
            ],
          ),
        ),
      ),
      onWillPop: () async {
        showDialog(context: context, 
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Are you sure you want to exit."),
              actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                      child: CustomButton(text: "OK", onPressed: (){
                        Navigator.pushAndRemoveUntil(context, 
                        CustomPageRoute(child: const HomeScreen(), direction: AxisDirection.right),
                        (route) => false);
                      }),
                    ),
                ],),
              )
            ],);
        });
        return false;
      }
    );
  }

  void calculateResult(){
    final userId = Provider.of<AuthProvider>(context, listen: false).uid;
    int correctAnswers = 0;
    for(int i = 0; i < quiz!.questions.length; i++){
      String id = quiz!.questions[i]['id'];
      if(answers?[id] != null && answers?[id]?["selectedOption"] == answers?[id]?["correctOption"]){
        correctAnswers++;
      }
    }
    
    final rp = Provider.of<ResultsProvider>(context, listen: false);

    ResultModel result = ResultModel(
      userId: userId,
      quizId: "",
      quizTitle: "",
      totalQuestions: quiz!.questions.length,
      correctAnswers: correctAnswers,
      submittedAt: "",
      answers: answers!
    );
    
    rp.calculateAndSetResult(
      context: context, 
      quiz: quiz!,
      result: result,
      onSuccess: (){
         Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const QuizResultScreen(),
          ),
          (route) => false);
      }
    );
    
  }
}

class OptionButton extends StatelessWidget {
  const OptionButton({super.key, required this.option, required this.onTap, required this.attempted});

  final String option;
  final bool attempted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mainColor),
        boxShadow: [BoxShadow(
          offset: const Offset(0, 5),
          blurRadius: 20,
          color: mainColor.withOpacity(0.23),
        )]
      ),
      child: Material(
        color: attempted ? mainColor : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(child: Text(option, style: TextStyle(color: attempted ? Colors.white : Colors.black87, fontSize: 18),)),
        ),
      ),
    );
  }
}