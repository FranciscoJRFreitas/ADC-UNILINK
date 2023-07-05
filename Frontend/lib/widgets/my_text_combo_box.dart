import 'package:flutter/material.dart';

class MyTextComboBox extends StatefulWidget {
  const MyTextComboBox({
    required this.hintText,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  final String hintText;
  final List<String> items;
  final String selectedValue;
  final Function(String?) onChanged;

  @override
  _MyTextComboBoxState createState() => _MyTextComboBoxState();
}

class _MyTextComboBoxState extends State<MyTextComboBox> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: _isHovering
                ? Theme.of(context).hoverColor
                : Theme.of(context)
                    .scaffoldBackgroundColor, // Change colors to what you want
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context)
                      .inputDecorationTheme
                      .border
                      ?.borderSide
                      .color ??
                  Colors.grey,
              width: Theme.of(context)
                      .inputDecorationTheme
                      .border
                      ?.borderSide
                      .width ??
                  1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.selectedValue,
              isExpanded: true,
              iconEnabledColor: Theme.of(context).primaryColor,
              dropdownColor: Theme.of(context).canvasColor,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).secondaryHeaderColor),
              onChanged: widget.onChanged,
              items: widget.items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              hint: Text(
                widget.hintText,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).secondaryHeaderColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
