import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import '../presentation/screen.dart';
import 'User.dart';
import 'FeedItem.dart';

Future<List<FeedItem>> fetchNews(int page) async {
  final response = await http.get(Uri.parse('https://www.fct.unl.pt/noticias?page=$page'));

  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    var newsItems = document.getElementsByClassName('views-row');

    List<FeedItem> feedItems = [];

    for (var newsItem in newsItems) {
      var pageElement = newsItem.querySelector('.views-field-title .field-content');
      var titleElement = newsItem.querySelector('.views-field-title .field-content a');
      var summaryElement = newsItem.querySelector('.views-field-field-resumo-value .field-content p');
      var dateElement = newsItem.querySelector('.views-field-created .field-content');
      var imageElement = newsItem.querySelector('.noticia-imagem .field-content a img');

      var feedItem = FeedItem(
        pageUrl: 'https://www.fct.unl.pt' + (titleElement?.attributes['href'] ?? ''),
        content: summaryElement?.text,
        //user: _users[0],  // Replace this with the appropriate user
        imageUrl: imageElement?.attributes['src'],
        likesCount: 0,  // Replace these with the appropriate values
        commentsCount: 0,  // Replace these with the appropriate values
        retweetsCount: 0,  // Replace these with the appropriate values
        //title: titleElement?.text,
        //date: dateElement?.text,
        tags: ['News', 'Clean', 'Getting fancy with it'],
      );

      feedItems.add(feedItem);
    }

    return feedItems;
  } else {
    throw Exception('Failed to load news...');
  }
}
