class Quiz{
  String id;
  String category;  
  String title;
  String createdAt;
  int time;
  int totalQuestions;
  List<Map<String, dynamic>> questions;

  Quiz({
    required this.id,
    required this.category, 
    required this.title, 
    required this.createdAt,
    required this.time, 
    required this.totalQuestions, 
    required this.questions,
  });

  //? from server to client (download data) map to object of Quiz class
  factory Quiz.fromMap(Map<String, dynamic> map){
    return Quiz(
      id: map['id'] ?? '', 
      category: map['category'].toString(), 
      title: map['title'] ?? '',
      createdAt: map['created_at'] ?? '',
      time: map['time'] ?? 0,
      totalQuestions: map['total_questions'] ?? 0,
      questions: map['questions'] ?? [],
    );
  }

  //? from client to server (upload data) object of Quiz class to map
  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "category": category,
      "title": title,
      "createdAt": createdAt,
      "time": time,
      "totalQuestions": totalQuestions,
      "questions": questions
    };
  }

}