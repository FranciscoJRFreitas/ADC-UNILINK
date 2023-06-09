import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';

class MyTextButton extends StatefulWidget {
  const MyTextButton({
    required this.buttonName,
    required this.onTap,
    required this.bgColor,
    required this.textColor,
    required this.height,
    this.alignment,
  });
  final String buttonName;
  final VoidCallback onTap;
  final Color bgColor;
  final Color textColor;
  final double height;
  final Alignment? alignment;

  @override
  _MyTextButtonState createState() => _MyTextButtonState();
}

class _MyTextButtonState extends State<MyTextButton> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      RawKeyboard.instance.addListener(_handleKeyEvent);
    } else {
      RawKeyboard.instance.removeListener(_handleKeyEvent);
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.alignment,
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.resolveWith(
            (states) => Colors.black12,
          ),
        ),
        onPressed: widget.onTap,
        child: Text(
          widget.buttonName,
          style: kButtonText.copyWith(color: widget.textColor),
        ),
      ),
    );
  }
}

