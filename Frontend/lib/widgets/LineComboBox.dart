import 'package:flutter/material.dart';

class LineComboBox extends StatefulWidget {
  const LineComboBox({
    Key? key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.icon,
    this.deleteIcon,
    this.onPressed,
  }) : super(key: key);

  final List<String> items;
  final String selectedValue;
  final Function(String?) onChanged;
  final IconData? icon;
  final IconData? deleteIcon;
  final void Function()? onPressed;

  @override
  _LineComboBoxState createState() => _LineComboBoxState();
}

class _LineComboBoxState extends State<LineComboBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          TextFormField(
            style: Theme.of(context).textTheme.bodyLarge,
            readOnly: true,
            controller: TextEditingController(text: ""),
            onTap: () {},
            decoration: InputDecoration(
              prefixIcon: Icon(widget.icon, color: Colors.grey),
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(92, 161, 161, 161))),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0)),
              focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0)),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                42.5, 0, 0, widget.deleteIcon != null ? 20.0 : 0.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.selectedValue,
                      iconEnabledColor: Theme.of(context).primaryColor,
                      dropdownColor: Theme.of(context).canvasColor,
                      style: Theme.of(context).textTheme.bodyLarge,
                      onChanged: widget.onChanged,
                      isExpanded: true,
                      items: widget.items
                          .map<DropdownMenuItem<String>>((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                widget.deleteIcon != null
                    ? IconButton(
                        hoverColor: Colors.transparent,
                        tooltip: "Clear Location",
                        icon: Icon(widget.deleteIcon, color: Colors.grey),
                        onPressed: widget.onPressed,
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
