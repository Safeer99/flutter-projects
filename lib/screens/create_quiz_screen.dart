import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/quiz_model.dart';
import 'package:quiz_app/provider/quizes_provider.dart';
import 'package:quiz_app/utils/utils.dart';
import '../constants.dart';
import '../widgets/custom_text_field.dart';
import './questions_preview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:numberpicker/numberpicker.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_page_route.dart';

class CreateQuizScreen extends StatefulWidget {

  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {

  final _formField = GlobalKey<FormState>();
  final _formFieldMain = GlobalKey<FormState>();

  final TextEditingController title = TextEditingController();
  final TextEditingController time = TextEditingController();
  final TextEditingController question = TextEditingController();
  final TextEditingController optionA = TextEditingController();
  final TextEditingController optionB = TextEditingController();
  final TextEditingController optionC = TextEditingController();
  final TextEditingController optionD = TextEditingController();
  final TextEditingController correctOption = TextEditingController();
  
  List<String>? categories;
  String? selectedCategory;

  @override
  void initState(){
    super.initState();
    setState((){
      categories =  Provider.of<QuizesProvider>(context, listen: false).getCategories;
    });
  }

  @override
  void dispose(){
    super.dispose();
    title.dispose();
    time.dispose();
    question.dispose();
    optionA.dispose();
    optionB.dispose();
    optionC.dispose();
    optionD.dispose();
    correctOption.dispose();
  }

  Future<String?> openFiles() async{
    String? csvFile;
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['csv']
    );
    if(pickedFile != null){
      PlatformFile file = pickedFile.files.first;
      setState((){
        csvFile = file.path;
      });
    }
    return csvFile;
  }

  Future<List> loadCsv(file) async{
    final rawData = await File(file).readAsString();
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData, eol: '\n' );
    List<Map<String, dynamic>> data = [];
    for(int i = 1; i < listData.length; i++){
      data.add({
        "id":  DateTime.now().microsecondsSinceEpoch.toString(),
        "question": listData[i][0].toString(),
        "options": [listData[i][1].toString(), listData[i][2].toString(), listData[i][3].toString(), listData[i][4].toString()],
        "correctOption": listData[i][5].toString()
      });
    }
    return data;
  }

  OutlineInputBorder customBorder(Color color){
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color));
  }

  @override
  Widget build(BuildContext context) {

    final qp = Provider.of<QuizesProvider>(context, listen: true);
    title.selection = TextSelection.fromPosition(TextPosition(offset: title.text.length));
    time.selection = TextSelection.fromPosition(TextPosition(offset: time.text.length));
    question.selection = TextSelection.fromPosition(TextPosition(offset: question.text.length));
    optionA.selection = TextSelection.fromPosition(TextPosition(offset: optionA.text.length));
    optionB.selection = TextSelection.fromPosition(TextPosition(offset: optionB.text.length));
    optionC.selection = TextSelection.fromPosition(TextPosition(offset: optionC.text.length));
    optionD.selection = TextSelection.fromPosition(TextPosition(offset: optionD.text.length));
    correctOption.selection = TextSelection.fromPosition(TextPosition(offset: correctOption.text.length));
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          centerTitle: true,
          backgroundColor: mainColor,
          title: const Text("Create Quiz"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: quizForm(size, qp)
          ),
        ),
      ),
      onWillPop: () async {
        qp.updateQuestionsList(clear: true);
        return true;
      },
    );
  }

  Widget quizForm(size, qp) => Form(
    key: _formFieldMain,
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //! TITLE of the quiz
          CustomTextField(
            iconDisplay: true,
            icon: Icons.title,
            controller: title,
            hintText: "Enter title for the quiz",
          ),
          const SizedBox(height: 20),
          //! Total time for the quiz
          TextFormField(
            cursorColor: mainColor,
            controller: time,
            onTap: (){
              showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: timeDialogBox(time)
              );
            },
            readOnly: true,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: "Time (hh:mm:ss)",
              hintStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500),
              enabledBorder: customBorder(Colors.black12),
              focusedBorder: customBorder(mainColor),
              errorBorder:  customBorder(Colors.red),
              focusedErrorBorder:  customBorder(Colors.red),
              prefixIcon:Container(
                padding: const EdgeInsets.all(15.0),
                child: Icon(Icons.watch_later,
                    color: Colors.grey.shade600, size: 25),)
            ),
            validator: (value) {
              if(value!.isEmpty){
                return "Please fill this field";
              }else if(!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$').hasMatch(value)){
                return "Invalid time";
              }
              return null;
            }
          ),
          const SizedBox(height: 20),
          //! Quiz category
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                items: categories?.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.split(" ").map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(" "))
                  );
                }).toList(), 
                hint: const Text("Category"),
                onChanged: (value){
                  setState((){
                    selectedCategory = value.toString();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 30,),
          const Text("Upload Questions", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20,),
          Text("Total Questions: ${qp.questionsList.length}", style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 20,),
          //! Questions upload or manual entry
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: size.width / 2.5,
                height: 50,
                child: CustomButton(
                  text: "Manual",
                  onPressed: (){
                    showModalBottomSheet(
                      isDismissible: true,
                      isScrollControlled: true,
                      enableDrag: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20)
                        )
                      ),
                      context: context,
                      builder: (BuildContext context){return bottomSheetForm(qp);}
                    );
                  },
                ),
              ),
              const Spacer(),
              SizedBox(
                width: size.width / 2.5,
                height: 50,
                child: ElevatedButton(
                  onPressed: (){
                    openFiles().then((value){
                      if(value != null){
                        loadCsv(value).then((value){
                            qp.updateQuestionsList(multipleQues: value);
                        });
                        showSnackBar(context, "File uploaded successfully");
                      }
                    });
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(secondaryColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                  child: const Text( "Upload CSV", style: TextStyle(fontSize: 16) ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          //! Preview Questions
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CustomButton(text: "Preview Questions", onPressed:(){
              if(qp.questionsList.isEmpty){
                showSnackBar(context, "No questions to preview");
                return;
              }
              Navigator.push(context,
                CustomPageRoute(child: const QuestionsPreview(), direction: AxisDirection.left)
              );
            })
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CustomButton(text: "Create", onPressed: (){
              if(_formFieldMain.currentState!.validate()){
                if(selectedCategory == null) {
                  showSnackBar(context, "Please select a category");
                  return;
                }
                else if(qp.questionsList.isEmpty){
                  showSnackBar(context, "Question list is empty!");
                  return;
                }
                sendData();
              }
            })
          ),
        ],
      ),
  );

  Widget bottomSheetForm(qp) => SingleChildScrollView(
    child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formField,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Question", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: "Enter Question", 
                  controller: question, 
                  icon: Icons.title, 
                  iconDisplay: false
                ),
                const SizedBox(height: 20),
                const Text("Options", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: "Enter option A", 
                  controller: optionA, 
                  icon: Icons.title, 
                  iconDisplay: false
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: "Enter option B", 
                  controller: optionB, 
                  icon: Icons.title, 
                  iconDisplay: false
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: "Enter option C", 
                  controller: optionC, 
                  icon: Icons.title, 
                  iconDisplay: false
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: "Enter option D", 
                  controller: optionD, 
                  icon: Icons.title, 
                  iconDisplay: false
                ),
                const SizedBox(height: 20),
                const Text("Correct Option", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: "Enter correct option", 
                  controller: correctOption, 
                  icon: Icons.title, 
                  iconDisplay: false
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(text: "Submit", onPressed: (){
                    if(_formField.currentState!.validate()){
                      setState(() {
                        qp.updateQuestionsList(question: {
                          "id": DateTime.now().microsecondsSinceEpoch.toString(),
                          "question": question.text,
                          "options": [
                            optionA.text, optionB.text, optionC.text, optionD.text
                          ],
                          "correctOption": correctOption.text
                        });
                      });
                      question.clear();
                      optionA.clear();
                      optionB.clear();
                      optionC.clear();
                      optionD.clear();
                      correctOption.clear();
                      showSnackBar(context, "Question added successfully");
                    }
                  })
                ),
                const SizedBox(height: 20),
              ]
            ),
          ),
        )
      ),
  );

  int stringToIntTimeConverter(String time){
    var splited = time.split(":");
    int hour = int.parse(splited[0]);
    int minute = int.parse(splited[1]);
    int second = int.parse(splited[2]);
    return ((hour*60*60) + (minute*60) + second);
  }

  void sendData(){
    final qp = Provider.of<QuizesProvider>(context, listen: false);

    Quiz newQuiz = Quiz(
      id: "",
      title: title.text,
      createdAt: "",
      category: selectedCategory!,
      totalQuestions: qp.questionsList.length,
      time: stringToIntTimeConverter(time.text),
      questions: qp.questionsList
    );

    qp.uploadQuizesToFirestore(context: context, quiz: newQuiz);
    title.clear();
    time.clear();
  }

}

StatefulBuilder Function(BuildContext context) timeDialogBox(TextEditingController controller) => (BuildContext context){
  int hours = 0, minutes = 0, seconds = 0; 
  return StatefulBuilder(builder: (context, StateSetter setState) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        height: 300,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            NumberPicker(
              minValue: 0, 
              maxValue: 24, 
              value: hours, 
              zeroPad: true,
              infiniteLoop: true,
              itemWidth: 80,
              itemHeight: 60,
              onChanged: (value) {
                setState(() {
                  hours = value;
                });  
              }
            ),
            NumberPicker(
              minValue: 0, 
              maxValue: 59, 
              value: minutes, 
              zeroPad: true,
              infiniteLoop: true,
              itemWidth: 80,
              itemHeight: 60,
              onChanged: (value) {
                setState(() {
                  minutes = value;
                });  
              }
            ),
            NumberPicker(
              minValue: 0, 
              maxValue: 59, 
              value: seconds, 
              zeroPad: true,
              infiniteLoop: true,
              itemWidth: 80,
              itemHeight: 60,
              onChanged: (value) {
                setState(() {
                  seconds = value;
                });  
              }
            )
          ],),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 100,
                height: 50,
                child: CustomButton(
                  text: "Cancel",
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(
                width: 100,
                height: 50,
                child: CustomButton(
                  text: "Ok",
                  onPressed: (){
                    controller.text = "${hours > 9 ? hours : "0$hours"}:${minutes > 9 ? minutes : "0$minutes"}:${seconds > 9 ? seconds : "0$seconds"}";
                    Navigator.pop(context);
                  },
                ),
              ),
          ],)
        ]),
      ),
    );
  });
};

