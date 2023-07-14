import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/provider/quizes_provider.dart';
import '../constants.dart';

class QuestionsPreview extends StatefulWidget {
  const QuestionsPreview({super.key});

  @override
  State<QuestionsPreview> createState() => _QuestionsPreviewState();
}

class _QuestionsPreviewState extends State<QuestionsPreview> {

  @override
  Widget build(BuildContext context) {

    final qp = Provider.of<QuizesProvider>(context, listen: true);
    List<Map<String,dynamic>> questions = qp.questionsList;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text("Questions")
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: DataTable(
            border: TableBorder.all(),
            columns:const [
              DataColumn(label: Text("")),
              DataColumn(label: Text("No.")),
              DataColumn(label: Text("Question")),
              DataColumn(label: Text("option A")),
              DataColumn(label: Text("option B")),
              DataColumn(label: Text("option C")),
              DataColumn(label: Text("option D")),
              DataColumn(label: Text("Correct Option")),
            ],
            rows: [
              for(int i = 0; i < questions.length; i++)
                buildRow((){
                  qp.updateQuestionsList(question: questions[i]);
                }, [
                  "delete",
                  (i + 1).toString(),
                  questions[i]["question"].toString(),
                  questions[i]["options"][0].toString(),
                  questions[i]["options"][1].toString(),
                  questions[i]["options"][2].toString(),
                  questions[i]["options"][3].toString(),
                  questions[i]["correctOption"].toString(),
                ])
            ],
          )
        ),
      )
    );
  }

  DataRow buildRow(onTap ,List<String> cells) => DataRow(
    cells: cells.map((cell) {
      return DataCell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: cell == "delete"  
            ? InkWell(
              onTap:onTap,
              child: const Icon(Icons.delete, color: Colors.red,)) 
            : Text(cell, softWrap: true,),
        )
      );
    }).toList()
  );
}
