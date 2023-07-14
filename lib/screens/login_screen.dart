import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/provider/auth_provider.dart';
import 'package:quiz_app/screens/home_screen.dart';
import 'package:quiz_app/screens/register_screen.dart';
import '../widgets/custom_button.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formField = GlobalKey<FormState>();
  bool _passwordVisible = false;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final _errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red));

  @override
  Widget build(BuildContext context) {

    final ap = Provider.of<AuthProvider>(context, listen: true);

    email.selection =
        TextSelection.fromPosition(TextPosition(offset: email.text.length));
    password.selection =
        TextSelection.fromPosition(TextPosition(offset: password.text.length));
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ap.isLoading == true
          ? const Center(
            child: CircularProgressIndicator(color: mainColor)
            )
          : Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 35),
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Form(
              key: _formField,
              child: Column(children: [
                Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: mainColor.withOpacity(0.2)),
                    child: Image.asset("assets/login.png")),
                const SizedBox(height: 20),
                const Text(
                  "Log In",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Welcome back !!!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                //! EMAIL FIELD
                TextFormField(
                  cursorColor: mainColor,
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: "Enter email address",
                    hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: mainColor)),
                    errorBorder: _errorBorder,
                    focusedErrorBorder: _errorBorder,
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Icon(Icons.email,
                          color: Colors.grey.shade600, size: 25),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your email";
                    }
                    else if(!RegExp(r'^[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*@[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*$').hasMatch(value)){ return "Enter valid email"; }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                //! PASSWORD FIELD
                TextFormField(
                  cursorColor: mainColor,
                  controller: password,
                  obscureText: !_passwordVisible,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: mainColor)),
                    errorBorder: _errorBorder,
                    focusedErrorBorder: _errorBorder,
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Icon(Icons.lock,
                          color: Colors.grey.shade600, size: 25),
                    ),
                    suffixIcon: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: InkWell(
                        child: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade600,
                            size: 25),
                        onTap: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your password";
                    }
                    if (value.length < 6) {
                      return "Password should be of atleast 6 characters.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                //! SIGNUP button
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CustomButton(
                      text: "Log In",
                      onPressed: () {
                        if (_formField.currentState!.validate()) {
                          sendDetails();
                          email.clear();
                          password.clear();
                        }
                      },
                    )),
                const SizedBox(height: 20),
                const Text(
                  "or",
                  style: TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                //! GOOGLE LOGIN 
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      ap.signInWithGoogle(context: context, onSuccess: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false);
                      });
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black54),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/google.png", height: 35,),
                        const SizedBox(width: 35,),
                        const Text("Sign In with google",
                        style: TextStyle(color: Colors.black38, fontSize: 16)),
                        const SizedBox(width: 70,)
                      ],
                    )
                  ),
                ),
                const SizedBox(height: 40),
                //! Signup page navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "First time here ?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()));
                      },
                    ),
                  ],
                ),
              ]),
            ),
          ),
            ),
          ),
    );
  }

  void sendDetails() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.logIn(
        context: context,
        email: email.text,
        password: password.text,
        onSuccess: () {
          ap.getUserDataFromFirebase().then((value) => ap
              .saveUserDataToSP()
              .then((value) =>
                  ap.setSignIn().then((value) => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false))));
        });
  }
}
