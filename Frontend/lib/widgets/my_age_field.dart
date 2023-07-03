import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class RegAge extends StatefulWidget {
  RegAge({
    Key? key,
    required this.textColor,
    required this.controller,
  }) : super(key: key);

  final Color textColor;
  final TextEditingController controller;
  bool wasPicked = false;

  @override
  State<RegAge> createState() => _RegAgeState();
}

class _RegAgeState extends State<RegAge> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.controller, //editing controller of this TextField
        decoration: InputDecoration(
          hintText: 'Enter your birthday',
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
            color: widget.wasPicked
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: Theme.of(context).secondaryHeaderColor),
        readOnly: true, // when true user cannot edit text
        onTap: () async {
          try {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(), //get today's date
                firstDate: DateTime(
                    1940),
                lastDate: DateTime.now());
            if (pickedDate != null) {
              String formattedDate =
                  DateFormat("yyyy-MM-dd").format(pickedDate);
              setState(() {
                widget.controller.text = formattedDate.toString();
                widget.wasPicked = true;
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
