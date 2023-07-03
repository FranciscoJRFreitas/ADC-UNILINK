import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class RegEvent extends StatefulWidget {
  RegEvent({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.firstDate,
    required this.lastDate,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final DateTime firstDate;
  final DateTime lastDate;
  bool wasPicked = false;

  @override
  State<RegEvent> createState() => _RegEventState();
}

class _RegEventState extends State<RegEvent> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.controller, //editing controller of this TextField
        decoration: InputDecoration(
          hintText: widget.hintText,
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
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
            );
            if (pickedDate != null) {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            background: Theme.of(context)
                                .scaffoldBackgroundColor, // Adjust to your preference
                            onBackground:
                                Colors.black, // Adjust to your preference
                            surface: Colors.white, // Adjust to your preference
                            onSurface:
                                Colors.black, // Adjust to your preference
                          ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedTime != null) {
                DateTime finalDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                String formattedDate =
                    DateFormat("yyyy-MM-dd HH:mm").format(finalDateTime);
                setState(() {
                  widget.controller.text = formattedDate.toString();
                  widget.wasPicked = true;
                });
              } else {
                print("Time not selected");
              }
            } else {
              print("Date not selected");
            }
          } catch (error) {
            print("Error when picking date or time: $error");
          }
        });
  }
}
