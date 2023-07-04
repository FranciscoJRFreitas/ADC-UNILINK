import 'package:flutter/material.dart';

class LineButton extends StatefulWidget {
  const LineButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.icon,
  }) : super(key: key);

  final String title;
  final Function() onPressed;
  final IconData? icon;

  @override
  _LineButtonState createState() => _LineButtonState();
}

class _LineButtonState extends State<LineButton> {
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
            onTap: () {},
            decoration: InputDecoration(
              prefixIcon: Icon(widget.icon, color: Colors.grey),
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(42.5, 0, 0, 0),
            child: TextButton(
              onPressed: widget.onPressed,
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
