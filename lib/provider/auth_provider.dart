import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/utils.dart';

class AuthProvider extends ChangeNotifier{
  bool _signedInWithGoogle = false;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _loading = false;
  bool get isLoading => _loading;

  String? _uid;
  String get uid => _uid!;
  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  AuthProvider(){
    checkSignIn();
  }

  Future<void> checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  Future setSignIn() async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future<void> signInWithGoogle({
    required BuildContext context,
    required Function onSuccess
  }) async {
    try {
      _loading = true;
      final GoogleSignInAccount? gUser = await googleSignIn.signIn();

      
      if(gUser != null){
        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        final credentials = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        await _firebaseAuth.signInWithCredential(credentials)
          .then((user) {
            if(user.user != null){
              _uid = user.user?.uid;  
              _signedInWithGoogle = true;
            } 
          }).catchError((e) {
            _loading = false;
            showSnackBar(context, e.message.toString());
            notifyListeners();
          });
      }else{
        _loading = false;
        notifyListeners();
      }
      

      if(_uid != null){
        await _firestore.collection("users").doc(_uid).get()
          .then((user){
            if(user.exists){
              getUserDataFromFirebase()
                .whenComplete(() {
                  saveUserDataToSP().whenComplete((){
                    setSignIn();
                    onSuccess();
                    _loading = false;
                    notifyListeners();
                  });
                });
            }else{
              _userModel = UserModel(
                createdAt: DateTime.now().microsecondsSinceEpoch.toString(),
                uid: _uid!,
                name: currentUser!.displayName!,
                email: currentUser!.email!,
                profilePic: currentUser!.photoURL!,
                role: "user",
              );
              saveUserDataToFirebase(context: context, userModel: userModel, onSuccess: (){
                saveUserDataToSP().whenComplete((){
                    setSignIn();
                    onSuccess();
                    _loading = false;
                    notifyListeners();
                  });
              });
            }
        }).catchError((e) {
            _loading = false;
            showSnackBar(context, e.message.toString());
            notifyListeners();
        });
      }else{
        _loading = false;
        notifyListeners();
      }

    // ignore: unused_catch_clause
    } on FirebaseAuthException catch (e) {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required BuildContext context, 
    required String email, 
    required String password, 
    required Function onSuccess
  }) async {
    _loading = true;
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)
        .then((user) {
          if(user.user != null){
            _uid = user.user?.uid;
            _loading = false;
            onSuccess();
            notifyListeners();
          } 
        })
        .catchError((e) {
          _loading = false;
          showSnackBar(context, e.message.toString());
          notifyListeners();
        });
    } on FirebaseAuthException catch (e) {
      _loading = false;
      showSnackBar(context, e.message.toString());
      notifyListeners();
    }
  }

  Future<void> logIn({
    required BuildContext context, 
    required String email, 
    required String password,
    required Function onSuccess
  }) async {
    _loading = true;
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password)
        .then((user) {
          if(user.user != null){
            _uid = user.user?.uid;
            _loading = false;
            onSuccess();
            notifyListeners();
          } 
        })
        .catchError((e) {
          _loading = false;
          showSnackBar(context, e.message.toString());
          notifyListeners();
        });
    } on FirebaseAuthException catch (e) {
      _loading = false;
      showSnackBar(context, e.message.toString());
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    if(_signedInWithGoogle){
      _signedInWithGoogle = false;
    }
    await googleSignIn.disconnect();
    _isSignedIn = false;
    sp.clear(); 
    notifyListeners();
  }

  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required Function onSuccess
  }) async {
    _loading = true;
    try{
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.uid = _uid!;

      _userModel = userModel;

      await _firestore.collection("users").doc(_uid).set(userModel.toMap())
        .then((value) {
          _loading = false;
          onSuccess();
          notifyListeners();

      }).catchError((e) {
          _loading = false;
          showSnackBar(context, e.message.toString());
          notifyListeners();
        });
    } on FirebaseAuthException catch(e){
      _loading = false;
      showSnackBar(context, e.message.toString());
      notifyListeners();
    }
  }

  Future getUserDataFromFirebase() async {
    _loading = true;
    await _firestore.collection("users").doc(_uid).get()
      .then((DocumentSnapshot snapshot) {
        _userModel = UserModel(
          name: snapshot['name'],
          email: snapshot['email'],
          createdAt: snapshot['createdAt'],
          profilePic: snapshot['profilePic'],
          uid: snapshot['uid'],
          role: snapshot['role'],
        );
      });
    _loading = false;
    notifyListeners();
  }

  Future<void> uploadProfilePic({
    required BuildContext context,
    required File profilePic,
    required Function onSuccess
  })async{
    try {
      _loading = true;
      String path = 'profilePic/$_uid';

      UploadTask uploadTask = _storage.ref().child(path).putFile(profilePic);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      _loading = false;
      onSuccess(downloadURL);
      notifyListeners();

    } on FirebaseAuthException catch(e){
      showSnackBar(context, e.message.toString());
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserDataOnFirebase({
    required BuildContext context,
    required UserModel user,
    required Function onSuccess
  }) async {
    try{
      _loading = true;
      _userModel = user;

      await _firestore.collection("users").doc(_uid).update(userModel.toMap())
        .then((value) {
          _loading = false;
          onSuccess();
          notifyListeners();

      }).catchError((e) {
          _loading = false;
          showSnackBar(context, e.message.toString());
          notifyListeners();
        });
    } on FirebaseAuthException catch(e){
      showSnackBar(context, e.message.toString());
      _loading = false;
      notifyListeners();
    }
  }

  Future saveUserDataToSP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("user_model", jsonEncode(userModel.toMap()));
    notifyListeners();
  }

  Future getDataFromSP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String data = sp.getString("user_model") ?? "";
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }
}
