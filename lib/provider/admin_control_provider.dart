import 'package:flutter/material.dart';
import 'package:quiz_app/models/quiz_model.dart';
import 'package:quiz_app/models/result_model.dart';
import 'package:quiz_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/utils/utils.dart';

class AdminControlProvider extends ChangeNotifier{

  bool _loading = false;
  bool get isLoading => _loading;

  int _totalUsers = 0;
  int get totalUsers => _totalUsers;

  int _totalQuizes = 0;
  int get totalQuizes => _totalQuizes;

  List<UserModel> _usersList = [];
  List<UserModel> get getUsersList => _usersList;

  List<Quiz> _quizesList = [];
  List<Quiz> get getQuizesList => _quizesList;

  List<ResultModel> _userResults = [];
  List<ResultModel> get getUserResults => _userResults;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminControlProvider();

  Future<void> getAllTheUsers({
    required BuildContext context,
  }) async {
    try {
      _loading = true;
      _usersList = [];
      await _firestore.collection("users").get()
        .then((QuerySnapshot querySnapshot) {
          _totalUsers = querySnapshot.docs.length;
          for(var docSnapshot in querySnapshot.docs){
            _usersList.add(UserModel(
              name: docSnapshot['name'], 
              email: docSnapshot['email'], 
              profilePic: docSnapshot['profilePic'], 
              createdAt: docSnapshot['createdAt'], 
              uid: docSnapshot['uid'], 
              role: docSnapshot['role']
            ));
          }
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

  Future<void> updateUserRole({
    required BuildContext context,
    required UserModel user,
    required Function onSuccess
  }) async {
    try{
      _loading = true;

      await _firestore.collection("users").doc(user.uid).update(user.toMap())
        .then((value) {
          _loading = false;
          onSuccess();
          notifyListeners();

      }).catchError((e) {
          _loading = false;
          showSnackBar(context, e.message.toString());
          notifyListeners();
        });
    } catch (e){
      showSnackBar(context, e.toString());
      _loading = false;
      notifyListeners();
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

  Future<void> getAllTheQuizes({
    required BuildContext context,
  }) async {
    try {
      _loading = true;
      await _firestore.collection("quizes").orderBy("createdAt", descending: true).get()
        .then((QuerySnapshot querySnapshot) {
          _totalQuizes = querySnapshot.docs.length;
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
          _quizesList = quizes;
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

  Future<void> getUserResultsFromFirestore({
    required BuildContext context,
    required String uid,
    required Function onSuccess,
  }) async {
    try {
      _loading = true;
      await _firestore.collection("results").where("userId", isEqualTo: uid).get()
        .then((QuerySnapshot querySnapshot) {
          List<ResultModel> results = [];
          for (var docSnapshot in querySnapshot.docs) {
            results.add(ResultModel(
                userId: docSnapshot['userId'],
                quizId: docSnapshot['quizId'],
                correctAnswers: docSnapshot['correctAnswers'],
                quizTitle: docSnapshot['quizTitle'],
                submittedAt: docSnapshot['submittedAt'],
                totalQuestions: docSnapshot['totalQuestions'],
                answers: docSnapshot['answers']
            ));
          }
          _userResults = results;
          _loading = false;
          notifyListeners();
          onSuccess();
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

}
