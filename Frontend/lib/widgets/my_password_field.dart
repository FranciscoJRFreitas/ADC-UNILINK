import 'package:flutter/material.dart';

class MyPasswordField extends StatelessWidget {
  const MyPasswordField({
    required this.isPasswordVisible,
    required this.onTap,
    required this.controller,
    required this.hintText,
    this.style,
    this.focusNode,
    this.onSubmitted,
  });

  final bool isPasswordVisible;
  final Function onTap;
  final TextEditingController controller;
  final String hintText;
  final TextStyle? style;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        onSubmitted: onSubmitted,
        focusNode: focusNode,
        controller: controller,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).secondaryHeaderColor),
        obscureText: isPasswordVisible,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () => onTap(),
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryIconTheme.color,
              ),
            ),
          ),
          contentPadding: EdgeInsets.all(20),
          hintText: hintText.isEmpty ? 'Password' : hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
