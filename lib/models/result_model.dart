class ResultModel {
  String userId;
  String quizId;
  String quizTitle;
  int totalQuestions;
  int correctAnswers;
  String submittedAt;
  Map<String, dynamic> answers;

  ResultModel({
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.submittedAt,
    required this.answers,
  });

  // from server to client
  factory ResultModel.fromMap(Map<String, dynamic> map){
    return ResultModel(
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      quizTitle: map['quizTitle'] ?? '',
      submittedAt: map['submittedAt'] ?? '',
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      answers: map['answers'] ?? {}
    );
  }

  // client to server (to map)
  Map<String, dynamic> toMap(){
    return {
      "userId": userId,
      "quizId": quizId,
      "quizTitle": quizTitle,
      "totalQuestions": totalQuestions,
      "correctAnswers": correctAnswers,
      "answers": answers,
      "submittedAt": submittedAt
    };
  }
}