import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final String? title;
  final bool active;
  final String? optionL;
  final String? optionR;
  final ValueChanged<bool>? onToggle;

  ToggleButton({
    this.title,
    required this.active,
    required this.optionL,
    required this.optionR,
    this.onToggle,
  });

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
      title: widget.title != null
          ? Text(
              widget.title ?? "",
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : null,
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.title != null ? double.infinity : 150,
        ),
        child: Switch(
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
            if (widget.onToggle != null) {
              widget.onToggle!(_isActive); // Call the callback
            }
          },
          activeTrackColor: Colors.blue.shade900,
          activeColor: Colors.blue.shade400,
        ),
      ),
      subtitle: Text(
        _isActive ? widget.optionR ?? "" : widget.optionL ?? "",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
