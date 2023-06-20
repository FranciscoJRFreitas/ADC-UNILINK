import 'dart:convert';
import 'dart:js';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:unilink2023/domain/ExtractJSONfile.dart';
import '../domain/FeedItem.dart';

var _firstTitleElement = null;
bool _hasNoMoreNews = false;
bool checked = true;

Future<List<FeedItem>> fetchNews(int page) async {
  if (_hasNoMoreNews) return [];

  final response =
      await http.get(Uri.parse('https://www.fct.unl.pt/noticias?page=$page'));

  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    var newsItems = document.getElementsByClassName('views-row');

    List<FeedItem> feedItems = [];
    List<String> defaultTags = (await extractFromFile("tags"));
    Map<String, String> defaultTagsMapping = Map.fromIterable(defaultTags,
        key: (tag) => tag.toLowerCase(), value: (tag) => tag);
    Map<String, List<String>> subtags = await extractSynonyms("subtags");

    Map<String, String> inverseSynonyms = {}; // inverse dictionary for subtags
    for (var baseWord in subtags.keys) {
      if (subtags[baseWord] == null) continue;
      for (var synonym in subtags[baseWord]!) {
        inverseSynonyms[synonym.toLowerCase()] = baseWord;
      }
    }

    for (var newsItem in newsItems) {
      var titleElement =
          newsItem.querySelector('.views-field-title .field-content a');

      if (titleElement == null) continue;

      print(titleElement.text);
      
      String txt = _firstTitleElement == null ? "placeholder" : _firstTitleElement.text;
      print(txt);
      if (titleElement.text == txt) {
        _hasNoMoreNews = true;
        return [];
      }
      if (checked) {
        _firstTitleElement = titleElement;
        checked = false;
      }

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

        Set<String?> tags = await extractKeywords(result);
        tags = tags
            .map((tag) {
              String lowerCaseTag = tag!.toLowerCase();
              if (inverseSynonyms.containsKey(lowerCaseTag)) {
                return inverseSynonyms[
                    lowerCaseTag]; // return the base word corresponding to the synonym
              }
              return tag; // return the original tag if it's not a synonym
            })
            .where((tag) => tag != null)
            .toSet();

        tags = tags
            .map((tag) => defaultTagsMapping.containsKey(tag!.toLowerCase())
                ? defaultTagsMapping[tag.toLowerCase()]
                : null)
            .where((tag) => tag != null)
            .toSet(); // include only tags present in defaultTags

        print(tags);

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
          tags: tags,
        );

        feedItems.add(feedItem);
      }
    }

    return feedItems;
  } else {
    throw Exception('Failed to load news...');
  }
}

Future<Map<String, List<String>>> extractSynonyms(String filename) async {
  String data = await rootBundle.loadString('assets/json/$filename.json');
  var jsonData = jsonDecode(data);

  Map<String, List<String>> subtags = {};
  for (var baseWord in jsonData['subtags'].keys) {
    List<String> wordSynonyms =
        List<String>.from(jsonData['subtags'][baseWord]);
    subtags[baseWord] = wordSynonyms.map((s) => s.toLowerCase()).toList();
  }
  return subtags;
}

Future<Set<String>> extractKeywords(String content) async {
  var client = http.Client();
  try {
    var uri = Uri.parse(
        'https://tm-websuiteapps.ipt.pt/yake/api/v2.0/extract_keywords');
    var request = http.MultipartRequest('POST', uri)
      ..fields['content'] = content
      ..fields['max_ngram_size'] = '1'
      ..fields['number_of_keywords'] = '10'
      ..fields['preTag'] = '<b style="color:white; background-color: #37517e;">'
      ..fields['posTag'] = '</b>';

    var streamedResponse = await client.send(request);
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> keywordData = data['keywords'];
      List<String> keywords =
          keywordData.map((keyword) => keyword['ngram'].toString()).toList();
      return keywords.toSet();
    } else {
      throw Exception('Failed to extract keywords...');
    }
  } finally {
    client.close();
  }
}
