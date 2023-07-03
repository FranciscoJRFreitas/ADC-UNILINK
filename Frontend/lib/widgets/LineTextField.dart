import 'package:flutter/material.dart';

class LineTextField extends StatelessWidget {
  LineTextField({this.title, this.icon, this.lableText, required this.controller, this.padding});
  final String? title;
  final IconData? icon;
  final String? lableText;
  final EdgeInsets? padding;

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge,
      onChanged: ((value) {}),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: lableText,
        hintText: title,
        hintStyle: Theme.of(context).textTheme.bodyMedium,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        contentPadding: padding ?? null,
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(92, 161, 161, 161))),
        errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0)),
        focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0)),
      ),
    );
  }
}
