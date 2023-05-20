import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final String? title;
  final bool active;
  final String? optionL;
  final String? optionR;

   ToggleButton({this.title, required this.active, required this.optionL, required this.optionR });

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.active;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title ?? "",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: Switch(
        value: _isActive,
        onChanged: (value) {
          setState(() {
            _isActive = value;
          });
        },
        activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.5),
        activeColor: Theme.of(context).primaryColor,
      ),
      subtitle: Text(
      _isActive ? widget.optionR ?? "" : widget.optionL ?? "",
      style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
