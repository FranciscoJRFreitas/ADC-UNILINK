import 'package:flutter/material.dart';
import '../constants.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    required this.small,
    required this.hintText,
    required this.inputType,
    required this.controller,
  });
  final bool small;
  final String hintText;
  final TextInputType inputType;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          //removi algumas coisas daqui
          contentPadding: EdgeInsets.all(20),
          hintText: hintText,
          hintStyle: small
              ? Theme.of(context).textTheme.bodySmall
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
