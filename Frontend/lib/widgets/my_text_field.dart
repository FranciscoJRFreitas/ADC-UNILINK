import 'package:flutter/material.dart';
import '../constants.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    required this.small,
    required this.hintText,
    required this.inputType,
    required this.controller,
    this.style,
    this.focusNode,
    this.onSubmitted,
  });
  final bool small;
  final String hintText;
  final TextInputType inputType;
  final TextEditingController controller;
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
        style: style != null
            ? style
            : small
                ? Theme.of(context).textTheme.bodySmall
                : Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).secondaryHeaderColor),
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          //removi algumas coisas daqui
          contentPadding: EdgeInsets.all(20),
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
