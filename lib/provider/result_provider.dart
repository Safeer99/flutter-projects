import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/models/result_model.dart';
import 'package:quiz_app/utils/utils.dart';
import '../models/quiz_model.dart';

class ResultsProvider extends ChangeNotifier {

  bool _loading = false;
  bool get isLoading => _loading;

  ResultModel? _result;
  ResultModel get getResult => _result!;

  List<ResultModel>? _allResults;
  List<ResultModel> get getAllResults => _allResults!;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ResultsProvider();

  Map<String, Map<String, String>> firebaseObjectToMap(data){
    Map<String, Map<String, String>> answers = {};
    for(int i = 0; i < data.length; i++){
      answers[data['questionId']] = {
        "selectedOption": data['selectedOption'], 
        "correctOption": data['correctOption'],
      };
    }
    return answers;
  }

  Future<void> calculateAndSetResult({
    required BuildContext context,
    required Quiz quiz,
    required ResultModel result,
    required Function onSuccess
  }) async {
    try {
      _loading = true;
      result.submittedAt = DateTime.now().microsecondsSinceEpoch.toString();
      result.quizId = quiz.id;
      result.quizTitle = quiz.title;

      _result = result;
      await _firestore.collection("results").add(result.toMap())
        .then((value) {
          onSuccess();
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

  Future<void> getResultsOfUserFromFirebase({
    required BuildContext context,
    required String userId,
    required Function onSuccess,
  }) async {
    try {
      _loading = true;
      await _firestore.collection("results").where("userId", isEqualTo: userId).orderBy("submittedAt", descending: true).get()
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

          _allResults = results;
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

}
