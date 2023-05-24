import 'package:flutter/material.dart';
import '../domain/Contact.dart';

class ContactCard extends StatelessWidget {
  final Contact? contact;

  ContactCard({
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // rounded corners
      ),
      elevation: 5,
      color: Color.fromARGB(255, 8, 52, 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(contact?.url ?? 'N/A'),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Color.fromARGB(255, 8, 52, 88), // light grey color for tags
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0), // add some space between tags and content
                Text(
                  contact?.name ?? 'N/A',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  contact?.phoneNumber ?? 'N/A',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
