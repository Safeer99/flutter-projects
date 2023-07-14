import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/models/quiz_model.dart';

class QuizDetailsScreen extends StatefulWidget {
  const QuizDetailsScreen({super.key, required this.quiz});

  final Quiz quiz;

  @override
  State<QuizDetailsScreen> createState() => _QuizDetailsScreenState();
}

class _QuizDetailsScreenState extends State<QuizDetailsScreen> {

  final TextEditingController titleController = TextEditingController();

  bool editingMode = false;

  @override
  Widget build(BuildContext context) {

    titleController.text = widget.quiz.title;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text("Quiz"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(26),
        child: ListView(children: [
          dataEditableField("Title", widget.quiz.title, Icons.title, titleController),
          const Divider(color: Colors.black38),
        ]),
      )
    );
  }

  Widget dataEditableField(String label, String data, IconData icon, TextEditingController controller){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 25, color: Colors.black54,),
              const SizedBox(width: 15,),
              Text(label, style: const TextStyle(fontSize: 15, color: Colors.black45),),
            ],
          ),
          const SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: TextField(
              cursorColor: mainColor,
              enabled: editingMode,
              controller: controller,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500),
              ),
            )
          ),
      ],),
    );
  }

}