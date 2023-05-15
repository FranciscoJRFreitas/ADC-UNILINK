import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String? imageUrl;
  final List<String>? tags;
  final String? content;

  CustomCard({
    required this.imageUrl,
    required this.tags,
    required this.content,
  });
/*
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            15), // <- Change this for more or less roundness
      ),
      color: Color.fromARGB(255, 8, 52, 88),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl ??
              'N/A'), // or you can use Image.asset() for local images
          Container(
            color: Color.fromARGB(
                255, 8, 52, 88), // specify the background color here
            child: Wrap(
              spacing: 6.0, // gap between tags
              runSpacing: 6.0, // gap between lines
              children: tags != null && tags!.isNotEmpty
                  ? tags!.map((tag) => Chip(label: Text(tag))).toList()
                  : <Widget>[],
            ),
          ),
          Container(
            color: Color.fromARGB(
                255, 8, 52, 88), // specify the background color here
            padding: const EdgeInsets.all(8.0),
            child: Text(content ?? 'N/A',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }*/
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
            child: Image.network(imageUrl ?? 'N/A'),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Color.fromARGB(255, 8, 52, 88), // light grey color for tags
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6.0, // gap between tags
                  runSpacing: 6.0, // gap between lines
                  children: tags != null && tags!.isNotEmpty
                      ? tags!.map((tag) => Chip(label: Text(tag))).toList()
                      : <Widget>[],
                ),
                SizedBox(
                    height: 8.0), // add some space between tags and content
                Text(
                  content ?? 'N/A',
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