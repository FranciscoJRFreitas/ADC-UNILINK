import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class regAge extends StatefulWidget {
  const regAge({
    Key key,
    @required this.textColor,
    @required this.controller,
  }) : super(key: key);

  final Color textColor;
  final TextEditingController controller;

  @override
  State<regAge> createState() => _regAgeState();
}

class _regAgeState extends State<regAge> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.controller, //editing controller of this TextField
        decoration: InputDecoration(
          hintText: 'Enter your birthday',
          hintStyle: TextStyle(color: Style.grey),
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
            color: Style.grey,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Style.grey),
            borderRadius: BorderRadius.circular(20.0),
          ),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            borderSide: BorderSide(color: Style.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            borderSide: BorderSide(width: 1, color: Style.grey),
          ),
        ),
        style: TextStyle(color: Style.grey),
        readOnly: true, // when true user cannot edit text
        onTap: () async {
          try {
            DateTime pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime(2010), //get today's date
                firstDate: DateTime(
                    1940), //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime(2010));
            if (pickedDate != null) {
              String formattedDate =
                  DateFormat("yyyy-MM-dd").format(pickedDate);
              setState(() {
                widget.controller.text = formattedDate.toString();
              });
            } else {
              print("Not selected");
            }
          } catch (error) {
            print("Error when picking date: $error");
          }
        });
  }
}
