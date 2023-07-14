import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/provider/auth_provider.dart';
import 'package:quiz_app/provider/result_provider.dart';
import '../constants.dart';
import '../models/result_model.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  List<ResultModel>? results;

  @override
  void initState(){
    super.initState();
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final rp = Provider.of<ResultsProvider>(context, listen: false);
    rp.getResultsOfUserFromFirebase(context: context, userId: ap.uid, onSuccess: () {
      setState(() {
        results = rp.getAllResults;
      });
    });
  }

  String timeConverter(time){
    int seconds = (DateTime.now().microsecondsSinceEpoch - int.parse(time)) ~/ 1000000;
    if(seconds < 60) return "$seconds seconds";
    if(seconds ~/ 60 < 60) return "${seconds ~/ 60} ${seconds ~/ 60 == 1 ? "minute" : "minutes"}";
    int minutes = seconds ~/ 60;
    if(minutes ~/ 60 < 24) return "${minutes ~/ 60} ${minutes ~/ 60 == 1 ? "hour" : "hours"}";
    int hours = minutes ~/ 60;
    if(hours ~/ 24 < 30) return "${hours ~/ 24} ${hours ~/ 24 == 1 ? "day" : "days"}";
    int days = hours ~/ 24;
    if(days ~/ 30 < 12) return "${days ~/ 30} ${days ~/ 30 == 1 ? "month" : "months"}";
    return "${days ~/ 30 ~/ 12} ${days ~/ 30 ~/ 12 == 1 ? "year" : "years"}";
  }

  @override
  Widget build(BuildContext context) {
    final rp = Provider.of<ResultsProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text("History"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: rp.isLoading 
          ? const Center(child: CircularProgressIndicator(color: mainColor,)) 
          : results!.isEmpty 
            ? const Center(child: Text("You haven't take any quiz yet!",textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontSize: 20)))
            : ListView(children: [
            for(int i = 0; i < results!.length; i++)
              customStripCard(results![i].quizTitle, results![i].submittedAt, results![i].correctAnswers, results![i].totalQuestions, i%3)
        ]),
      )
    );
  }

  Widget customStripCard(String title, String submittedAt, int correctAnswers, int totalQuestions, int number){
    return Padding(
      padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
            onTap: (){},
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
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis, color: card[number]),),
                      const SizedBox(height: 4,),
                      // Text("Score: $correctAnswers/$totalQuestions", style: TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis, color: card[number]),),
                      Text("${timeConverter(submittedAt)} ago", style: TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis, color: card[number]),),
                    ],
                  )
                ),
                CircularPercentIndicator(
                  radius: 24,
                  progressColor: card[number],
                  center: Text("${((correctAnswers/totalQuestions)*100).toInt()}%", style: TextStyle(color: card[number])),
                  percent: correctAnswers/totalQuestions,
                ),
                const SizedBox(width: 7)
              ],
            ),
          ),
        )
      ),
    );
  }
}