import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineDateField extends StatefulWidget {
  LineDateField({
    Key? key,
    required this.controller,
    required this.title,
    this.icon,
    this.lableText,
  }) : super(key: key);

  final TextEditingController controller;
  final String title;
  final IconData? icon;
  final String? lableText;
  bool wasPicked = false;

  @override
  _LineDateFieldState createState() => _LineDateFieldState();
}

class _LineDateFieldState extends State<LineDateField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      style: Theme.of(context).textTheme.bodyLarge,
      readOnly: true,
      onTap: () async {
        try {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate: DateTime(1940),
              lastDate: DateTime.now());
          if (pickedDate != null) {
            String formattedDate = DateFormat("yyyy-MM-dd").format(pickedDate);
            setState(() {
              widget.controller.text = formattedDate.toString();
              widget.wasPicked = true;
            });
          } else {
            print("Date not selected");
          }
        } catch (error) {
          print("Error when picking date: $error");
        }
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          widget.icon,
          color: widget.wasPicked ? Theme.of(context).secondaryHeaderColor : Colors.grey,
        ),
        labelText: widget.lableText,
        hintText: widget.title,
        hintStyle: Theme.of(context).textTheme.bodyMedium,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
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
