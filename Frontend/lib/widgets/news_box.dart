import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCard extends StatelessWidget {
  final String? imageUrl;
  final Set<String?>? tags;
  final String? content;
  final String? title;
  final String? date;
  final Function(String)? onTagClick;

  CustomCard({
    required this.imageUrl,
    required this.tags,
    required this.content,
    required this.title,
    required this.date,
    this.onTagClick,
  });

  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate available height and width
      final double availableHeight = constraints.maxHeight;
      final double availableWidth = constraints.maxWidth;

      // Calculate card height and font size based on available space
      final double cardHeight =
          availableHeight < MediaQuery.of(context).size.height
              ? availableHeight / 5
              : MediaQuery.of(context).size.height / 5;
      final double fontSize = availableWidth < 400 ? 12 : 17;

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // rounded corners
        ),
        elevation: 5,
        color: Theme.of(context).primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: // Check if imageWidth is not null
                  Image.network(
                imageUrl ?? 'N/A',
                width: double.infinity,
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Theme.of(context).primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'N/A',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 20),
                  ),

                  if (date != null)
                    Text(
                      date!.trimLeft(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                  SizedBox(height: 10.0),
                  Wrap(
                    spacing: 6.0, // gap between tags
                    runSpacing: 6.0, // gap between lines
                    children: tags != null && tags!.isNotEmpty
                        ? tags!
                            .map((tag) => GestureDetector(
                                  onTap: () => onTagClick?.call(tag),
                                  child: Chip(label: Text(tag!)),
                                ))
                            .toList()
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
        borderOnForeground: true,
      );
    });
  }
/*
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // rounded corners
      ),
      elevation: 5,
      color: Theme.of(context).primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: imageWidth == false // Check if imageWidth is not null
                ? Image.network(
                    imageUrl ?? 'N/A',
                  )
                : Image.network(imageUrl ?? 'N/A'),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).primaryColor,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center horizontally
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                // your children
                Text(
                  title ?? 'N/A',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontSize: 20),
                ),

                if (date != null)
                  Text(
                    date!.trimLeft(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                SizedBox(height: 10.0),
                Wrap(
                  spacing: 6.0, // gap between tags
                  runSpacing: 6.0, // gap between lines
                  children: tags != null && tags!.isNotEmpty
                      ? tags!
                          .map((tag) => GestureDetector(
                                onTap: () => onTagClick?.call(tag),
                                child: Chip(label: Text(tag!)),
                              ))
                          .toList()
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
  }*/
}
