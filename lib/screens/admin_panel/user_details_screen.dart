import 'package:flutter/material.dart';
import 'package:quiz_app/models/result_model.dart';
import 'package:quiz_app/provider/admin_control_provider.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/user_model.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key, required this.user});

  final UserModel user;

  double averageScoreCalculate(List<ResultModel> results){
    double sum = 0;
    for (var element in results) {
      sum += (element.correctAnswers/element.totalQuestions) * 100;
    }
    return sum / results.length;
  }

  double successRateCalculate(List<ResultModel> results){
    double wins = 0;
    for(var element in results) {
      if(element.correctAnswers >= element.totalQuestions/2) wins++;
    }
    return (wins/results.length)*100;
  }

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<AdminControlProvider>(context, listen: true);
    final List<ResultModel> results = up.getUserResults;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text("User Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(26),
        child: ListView(
          children: [
            header(user),
            const Text("Progress", style: TextStyle(fontSize: 23, color: Colors.black87),),
            const Divider(color: Colors.black38),
            const SizedBox(height:5),
            dataField("Quiz Attempted", results.length.toString()),
            dataField("Average Score", averageScoreCalculate(results).toStringAsFixed(2)),
            dataField("Success Rate", "${successRateCalculate(results).toStringAsFixed(1)}%"),
          ],
        )
      )
    );
  }

  Widget header(UserModel user){
    return Column(children:[
      Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(
            spreadRadius: 2,
            blurRadius: 10,
            color:mainColor.withOpacity(0.1)
          )],
          shape: BoxShape.circle,
          image: user.profilePic != "" ? DecorationImage(
            fit: BoxFit.contain,
            image: NetworkImage(user.profilePic),
          ) : null,
        ),
        child: user.profilePic == "" ? const Icon(Icons.account_circle, size: 110, color: mainColor,) : null,
      ),
      const SizedBox(height: 15),
      Text(user.name, textAlign: TextAlign.center, style: const TextStyle( fontSize: 25 ),),
      const SizedBox(height: 3),
      Text(user.email, textAlign: TextAlign.center, style: const TextStyle( color: Colors.black45),),
      const SizedBox(height: 3),
      Text(user.role == "admin" ? "Admin" : "" , textAlign: TextAlign.center, style: const TextStyle( color: Color.fromARGB(255, 24, 150, 28))),
      const SizedBox(height: 30),
    ]);
  }

  Widget dataField(String title, String data){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(children: [
        Text(title, style: const TextStyle(fontSize: 15, color: Colors.black54)),
        const Spacer(),
        Text(data, style: const TextStyle(fontSize: 15, color: Colors.black54))
      ],),
    );
  }

}