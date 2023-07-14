import 'package:flutter/material.dart';
import '../constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, required this.hintText, required this.controller, required this.icon, required this.iconDisplay});

  final bool iconDisplay;
  final IconData icon;
  final TextEditingController controller;
  final String hintText;

  OutlineInputBorder customBorder(Color color){
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color));
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: mainColor,
      controller: controller,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500),
        enabledBorder: customBorder(Colors.black12),
        focusedBorder: customBorder(mainColor),
        errorBorder:  customBorder(Colors.red),
        focusedErrorBorder:  customBorder(Colors.red),
        prefixIcon: iconDisplay ? Container(
          padding: const EdgeInsets.all(15.0),
          child: Icon(icon,
              color: Colors.grey.shade600, size: 25),
        ) : null,
      ),
      validator: (value) {
        if(value!.isEmpty){
          return "Please fill this field";
        }
        return null;
      }
    );
  }
}