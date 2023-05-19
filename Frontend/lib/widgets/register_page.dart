import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class regAge extends StatefulWidget {
  const regAge({
    Key? key,
    required this.textColor,
    required this.controller,
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
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
            color: Theme.of(context).primaryIconTheme.color,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        readOnly: true, // when true user cannot edit text
        onTap: () async {
          try {
            DateTime? pickedDate = await showDatePicker(
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
