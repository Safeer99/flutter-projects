class UserModel {
  String name;
  String email;
  String profilePic;
  String createdAt;
  String uid;
  String role;

  UserModel({
    required this.name, 
    required this.email, 
    required this.profilePic, 
    required this.createdAt, 
    required this.uid,
    required this.role
  });

  // from server to client
  factory UserModel.fromMap(Map<String, dynamic> map){
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
      createdAt: map['createdAt'] ?? '',
      uid: map['uid'] ?? '',
      role: map['role'] ?? 'user'
    );
  }

  // client to server (to map)
  Map<String, dynamic> toMap(){
    return {
      "name": name,
      "email": email,
      "profilePic": profilePic,
      "createdAt": createdAt,
      "uid": uid,
      "role": role
    };
  }
}