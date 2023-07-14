import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/screens/home_screen.dart';
import 'package:quiz_app/screens/welcome_screen.dart';
import '../constants.dart';
import '../provider/auth_provider.dart';
import '../utils/utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    final ap = Provider.of<AuthProvider>(context, listen: false);

    Timer(const Duration(seconds: 3), () async{
      if(ap.isSignedIn){
        await ap.getDataFromSP().whenComplete(() => 
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen())
          )
        ).catchError((e) {
          showSnackBar(context, e.message.toString());
        });
      }else{
        Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (context) => const WelcomeScreen())
        );
      }
    });

  }  


  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: mainColor.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/quiz.png", width: size.width * 0.6),
              const SizedBox(height: 50),
              const Text("QUIZ TIME", 
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, wordSpacing: 10)
              ),
            ],
          )
        ),
      )
    );
  }
}