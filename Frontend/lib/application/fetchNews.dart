import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import '../presentation/screen.dart';
import '../domain/User.dart';
import '../domain/FeedItem.dart';

Future<List<FeedItem>> fetchNews(int page) async {
  final response =
      await http.get(Uri.parse('https://www.fct.unl.pt/noticias?page=$page'));

  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    var newsItems = document.getElementsByClassName('views-row');

    List<FeedItem> feedItems = [];
    List<String> defaultTags = [
      'Informática',
      'Mecânica',
      'Industrial',
      'Biologia',
      'Bioquímica',
      'Matemática',
      'Ambiente',
      'Civil',
      'Biomédica',
      'Eletrotécnica',
      'Física',
      'Materiais',
      'Nanotecnologias',
      'Mestrado',
      'Licenciatura',
      'Doutoramento',
      'Investigação'
    ];

    for (var newsItem in newsItems) {
      var titleElement =
          newsItem.querySelector('.views-field-title .field-content a');
      var summaryElement = newsItem
          .querySelector('.views-field-field-resumo-value .field-content p');
      var dateElement =
          newsItem.querySelector('.views-field-created .field-content');
      var imageElement =
          newsItem.querySelector('.noticia-imagem .field-content a img');

      if (newsItem.querySelector('.views-field-title .field-content') == null) {
        continue;
      }

      final responseText = await http.get(Uri.parse(
          'https://www.fct.unl.pt' + (titleElement?.attributes['href'] ?? '')));

      if (responseText.statusCode == 200) {
        var document = parser.parse(responseText.body);
        var textNews = document.getElementsByClassName('noticia-corpo');

        RegExp exp = new RegExp(r'<[^>]*>|&[^;]+;');

        String result = '';
        for (var item in textNews) {
          result += item.text.replaceAllMapped(exp, (Match m) {
            return "";
          });
        }

        List<String> tags = await extractKeywords(result);

        List<String> filteredTags = tags.where((tag) => defaultTags.contains(tag)).toList();

        print(filteredTags);

        var feedItem = FeedItem(
          pageUrl: 'https://www.fct.unl.pt' +
              (titleElement?.attributes['href'] ?? ''),
          content: summaryElement?.text,
          //user: _users[0],  // Replace this with the appropriate user
          imageUrl: imageElement?.attributes['src'],
          likesCount: 0, // Replace these with the appropriate values
          commentsCount: 0, // Replace these with the appropriate values
          retweetsCount: 0, // Replace these with the appropriate values
          title: titleElement?.text,
          date: dateElement?.text,
          tags: filteredTags,
        );

        feedItems.add(feedItem);
      }
    }

    return feedItems;
  } else {
    throw Exception('Failed to load news...');
  }
}

Future<List<String>> extractKeywords(String content) async {
  var client = http.Client();
  try {
    var uri = Uri.parse(
        'https://tm-websuiteapps.ipt.pt/yake/api/v2.0/extract_keywords');
    var request = http.MultipartRequest('POST', uri)
      ..fields['content'] = content
      ..fields['max_ngram_size'] = '3'
      ..fields['number_of_keywords'] = '20'
      ..fields['preTag'] = '<b style="color:white; background-color: #37517e;">'
      ..fields['posTag'] = '</b>';

    var streamedResponse = await client.send(request);
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> keywordData = data['keywords'];
      List<String> keywords = keywordData.map((keyword) => keyword['ngram'].toString()).toList();
      return keywords;
    } else {
      throw Exception('Failed to extract keywords...');
    }
  } finally {
    client.close();
  }
}


