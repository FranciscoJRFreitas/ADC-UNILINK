import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import 'package:unilink2023/constants.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

class CustomCard extends StatefulWidget {
  final String? imageUrl;
  final Set<String?>? tags;
  final String? content;
  final String? title;
  final String? date;
  final int index;
  final bool? isSingleCrossAxisCount;
  final Function(String)? onTagClick;

  CustomCard({
    required this.imageUrl,
    required this.tags,
    required this.content,
    required this.title,
    required this.date,
    required this.index,
    this.isSingleCrossAxisCount,
    this.onTagClick,
  });

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> with WidgetsBindingObserver {
  late double fontSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fontSize = 2.7 * MediaQuery.of(context).size.height * 0.01;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    setState(() {
      fontSize = 5 * MediaQuery.of(context).size.height * 0.01;
    });
  }

  @override
  Widget build(BuildContext context) {
    /*Color cardColor = widget.index % 2 == 0
        ? Theme.of(context).primaryColor
        : Theme.of(context)
            .primaryColor
            .withGreen(Theme.of(context).primaryColor.green - 40)
            .withRed(Theme.of(context).primaryColor.red - 10);*/
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate available height and width
      final double availableHeight = constraints.maxHeight;
      final double cardHeight =
          availableHeight < MediaQuery.of(context).size.height
              ? availableHeight / 5
              : MediaQuery.of(context).size.height / 5;
      final double minFontSize = 18.0;
      final double maxFontSize = 23.0;

      double cardMaxHeight;
      if (widget.isSingleCrossAxisCount ?? false) {
        cardMaxHeight = double.infinity;
      } else {
        cardMaxHeight = cardHeight;
      }

      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400, maxHeight: cardMaxHeight),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          color: Theme.of(context).primaryColor,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Provider.of<ThemeNotifier>(context).currentTheme ==
                          kDarkTheme
                      ? Colors.blue.shade900
                      : Colors.black54, // shadow color
                  offset: Offset(5, 5), // Offset in x and y axes
                  blurRadius: 10, // blur effect
                  spreadRadius: 3, // spread effect
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: // Check if imageWidth is not null
                      //     Image.network(
                      //   widget.imageUrl ?? 'N/A',
                      //   width: double.infinity,
                      //   fit: BoxFit.cover,
                      //   height: 200,
                      // ),
                      profilePicture(context),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title ?? 'N/A',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontSize: max(
                                    min(fontSize, maxFontSize), minFontSize)),
                      ),
                      if (widget.date != null)
                        Text(
                          widget.date!.trimLeft(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      SizedBox(height: 10.0),
                      Wrap(
                        spacing: 6.0, // gap between adjacent tags
                        runSpacing: 6.0, // gap between lines of tags
                        children: widget.tags != null && widget.tags!.isNotEmpty
                            ? widget.tags!
                                .map(
                                  (tag) => GestureDetector(
                                    onTap: () => widget.onTagClick?.call(tag),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color:
                                            Provider.of<ThemeNotifier>(context)
                                                        .currentTheme ==
                                                    kDarkTheme
                                                ? Colors.blue.shade900
                                                : Colors.blue.shade300,
                                        border: Border.all(
                                            color: Provider.of<ThemeNotifier>(
                                                            context)
                                                        .currentTheme ==
                                                    kDarkTheme
                                                ? Colors.blue.shade900
                                                : Colors.blue.shade300),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Provider.of<ThemeNotifier>(
                                                              context)
                                                          .currentTheme ==
                                                      kDarkTheme
                                                  ? Colors.blue.shade900
                                                      .withOpacity(0.5)
                                                  : Colors.blue.shade300
                                                      .withOpacity(0.8),
                                              offset: Offset(0, 25),
                                              blurRadius: 3,
                                              spreadRadius:
                                                  -10 // changes position of shadow
                                              ),
                                        ],
                                      ),
                                      child: Text(
                                        "#" + tag!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList()
                            : <Widget>[],
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        widget.content ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: max(min(fontSize - 3, maxFontSize - 3),
                                minFontSize - 3)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget profilePicture(BuildContext context) {
    return InkWell(
      onTap: () {
        //edit image link click as per your need.
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 200,
            child: Container(
              child: ClipRRect(
                  borderRadius: BorderRadius.horizontal(),
                  child: picture(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget picture(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl ?? 'N/A', // pass the imageUrl directly
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      imageBuilder: (context, imageProvider) => GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return Dialog(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    PhotoView(
                      imageProvider: imageProvider,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 15.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Image(
          image: imageProvider,
          fit: BoxFit.cover,  // or BoxFit.fill if you want to fill and distort the image to fit the container.
        ),
      ),
    );
  }
}
