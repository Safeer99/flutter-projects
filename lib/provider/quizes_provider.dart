import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/utils/utils.dart';
import '../models/quiz_model.dart';
import 'package:firebase_database/firebase_database.dart';

class QuizesProvider extends ChangeNotifier {

  bool _loading = false;
  bool get isLoading => _loading;

  List<String> _categories = ['Science', 'Entertainment'];
  List<String> get getCategories => _categories;

  String? _selectedCategory;
  String get getSelectedCategory => _selectedCategory!;

  List<Quiz>? _quizes;
  List<Quiz> get getQuizes => _quizes!;

  List<Quiz>? _recommendedQuizes;
  List<Quiz> get getRecommendedQuizes => _recommendedQuizes!;

  Quiz? _selectedQuiz;
  Quiz get getSelectedQuiz => _selectedQuiz!;

  List<Map<String, dynamic>> _questionsList = [];
  List<Map<String, dynamic>> get questionsList => _questionsList;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  QuizesProvider();

  void setQuiz(index, fromRecommendedList){
    if(fromRecommendedList) {
      _selectedQuiz = _recommendedQuizes?[index];
    }else{
      _selectedQuiz = _quizes?[index];
    }
  }

  List<Map<String, dynamic>> firebaseObjectToMap(data){
    List<Map<String, dynamic>> questions = [];
    for(int i = 0; i < data.length; i++){
      questions.add({
        'id': data[i]['id'],
        'question': data[i]['question'],
        'options': [ data[i]['options'][0].toString(), data[i]['options'][1].toString(), data[i]['options'][2].toString(), data[i]['options'][3].toString() ],
        'correctOption': data[i]['correctOption']
      });
    }
    return questions;
  }

  //! GET recently uploaded quizes from firestore
  Future<void> getRecommendedQuizesFromFirestore({required BuildContext context}) async{
    try {
      _loading = true;
      await _firestore.collection("quizes").orderBy("createdAt", descending: true).limit(10).get()
        .then((QuerySnapshot querySnapshot) {
          List<Quiz> quizes = [];
          for (var docSnapshot in querySnapshot.docs) {
            List<Map<String, dynamic>> questions = firebaseObjectToMap(docSnapshot['questions']);
            quizes.add(Quiz(
                id: docSnapshot['id'],
                category: docSnapshot['category'],
                title: docSnapshot['title'],
                createdAt: docSnapshot['createdAt'],
                time: docSnapshot['time'],
                totalQuestions: docSnapshot['totalQuestions'],
                questions: questions
            ));
          }
          _recommendedQuizes = quizes;
          _loading = false;
          notifyListeners();

        }).catchError((e) {
          showSnackBar(context, e.toString());
          _loading = false;
          notifyListeners();
      });
    } catch (e) {
      showSnackBar(context, e.toString());
      _loading = false;
      notifyListeners();
    }
  }

  //! GET quizes from the firestore based on the selected category
  Future<void> getQuizesBasedOnCategory({
    required BuildContext context,
    required String category, 
    required Function onSuccess
  }) async {
    try {
      _loading = true;
      await _firestore.collection("quizes").where("category", isEqualTo: category).orderBy("createdAt", descending: true).get()
        .then((QuerySnapshot querySnapshot) {
          List<Quiz> quizes = [];
          for (var docSnapshot in querySnapshot.docs) {
            List<Map<String, dynamic>> questions = firebaseObjectToMap(docSnapshot['questions']);
            quizes.add(Quiz(
                id: docSnapshot['id'],
                category: docSnapshot['category'],
                title: docSnapshot['title'],
                createdAt: docSnapshot['createdAt'],
                time: docSnapshot['time'],
                totalQuestions: docSnapshot['totalQuestions'],
                questions: questions
            ));
          }
          _selectedCategory = category;
          _quizes = quizes;
          _loading = false;
          onSuccess();
          notifyListeners();
        }).catchError((e) {
          showSnackBar(context, e.toString());
          _loading = false;
          notifyListeners();
      });
      
    } catch (e) {
      showSnackBar(context, e.toString());
      _loading = false;
      notifyListeners();
    }
  }

  //? ADMIN 

  //! quiz creating questions preview
  void updateQuestionsList({Map<String, dynamic> question = const {}, List<Map<String, dynamic>> multipleQues = const [], bool clear = false}){
    if(clear){
      _questionsList = [];
      return;
    }
    if(multipleQues.isNotEmpty){
      _questionsList = [...questionsList, ...multipleQues];
      return;
    }
    for(int i = 0; i < _questionsList.length; i++){
      if(_questionsList[i]['id'] == question['id']){
        _questionsList.removeAt(i);
        notifyListeners();
        return;
      }
    }
    _questionsList.add(question);
    notifyListeners();
  }

  Future<void> getCategoriesFromFirestore({required BuildContext context}) async {
    try {
      _loading = true;
      await _firestore.collection("meta-data").doc("categories").get()
        .then((DocumentSnapshot doc) {
          _categories = List<String>.from(doc['categories'] as List);
          _loading = false;
          notifyListeners();
        }).catchError((e) {
          showSnackBar(context, e.toString());
          _loading = false;
          notifyListeners();
      });
      
    } catch (e) {
      showSnackBar(context, e.toString());
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategoriesInFirestore({required BuildContext context, required List categoriesList}) async {
    try {
      _loading = true;
      for(int i = 0; i < categoriesList.length; i++){
        if(_categories.contains(categoriesList[i])){
          _categories.remove(categoriesList[i]);
        }else{
          _categories.add(categoriesList[i]);
        }
      }
      await _firestore.collection("meta-data").doc("categories").update({"categories": _categories})
        .then((value) {
          _loading = false;
          notifyListeners();
        }).catchError((e) {
          showSnackBar(context, e.toString());
          _loading = false;
          notifyListeners();
      });
      
    } catch (e) {
      showSnackBar(context, e.toString());
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> uploadQuizesToFirestore({
    required BuildContext context,
    required Quiz quiz
  }) async {
    try {
      _loading = true;
      DatabaseReference ref=FirebaseDatabase.instance.ref();
      String? uniqueId = ref.push().key;

      quiz.createdAt = DateTime.now().microsecondsSinceEpoch.toString();
      quiz.id = uniqueId!;

      _questionsList = [];

      await _firestore.collection('quizes').doc(uniqueId).set(quiz.toMap())
        .then((value) {
            showSnackBar(context, "Quiz created successfully.");
            _loading = false;
            notifyListeners();
        }).catchError((e) {
            showSnackBar(context, e.toString());
            _loading = false;
            notifyListeners();
      });

    } catch (e) {
      showSnackBar(context, e.toString());
      _loading = false;
      notifyListeners();
    }
  }


  Future<void> readJson() async {
    final String response = await rootBundle.loadString("assets/data.json");
    final data = await json.decode(response);
    List qs = [];
    for(int i = 0; i < data.length; i++){
      Map a = {
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'question': data[i]['question'],
        'options': [
          data[i]['incorrect_answers'][0],
          data[i]['incorrect_answers'][1],
          data[i]['correct_answer'],
          data[i]['incorrect_answers'][2],
        ],
        'correctOption': data[i]['correct_answer']
      };
      qs.add(a);
    }
    DatabaseReference ref=FirebaseDatabase.instance.ref();
    String? uniqueId = ref.push().key;
    await _firestore.collection('quizes').doc(uniqueId).set({
      "id": uniqueId,
      "category": "General Knowledge",
      "time": 100,
      "totalQuestions": data.length,
      "createdAt": DateTime.now().microsecondsSinceEpoch.toString(),
      "title": "Brain Burst",
      "questions": qs,
    });
  }
}
