import 'package:flutter/material.dart';
import '../constants.dart';

class MyTextComboBox extends StatelessWidget {
  const MyTextComboBox({
    Key key,
    @required this.hintText,
    @required this.items,
    @required this.selectedValue,
    @required this.onChanged,
  }) : super(key: key);
  final String hintText;
  final List<String> items;
  final String selectedValue;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            iconEnabledColor: Colors.white,
            dropdownColor: kBackgroundColor,
            style: kBodyText.copyWith(color: Colors.white),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            hint: Text(
              hintText,
              style: kBodyText,
            ),
          ),
        ),
      ),
    );
  }
}

