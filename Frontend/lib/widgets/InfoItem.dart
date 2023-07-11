import 'package:flutter/material.dart';

class InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  InfoItem({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme
            .of(context)
            .primaryIconTheme
            .color,
      ),
      title: Text(
        title,
        style: Theme
            .of(context)
            .textTheme
            .bodyLarge,
      ),
      subtitle: Text(
        value,
        style: Theme
            .of(context)
            .textTheme
            .bodyMedium,
      ),
    );
  }
}