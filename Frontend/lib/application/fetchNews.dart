import 'dart:convert';
import 'dart:html';

import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart';
import 'package:unilink2023/domain/ExtractJSONfile.dart';
import '../domain/FeedItem.dart';

var _firstTitleElement = null;
bool _hasNoMoreNews = false;
bool checked = true;

bool isFetched(){
  return _hasNoMoreNews;
}

Future<List<dom.Element>> getNewsItems(page) async {
  final response =
      await http.get(Uri.parse('https://www.fct.unl.pt/noticias?page=$page'));
  var document = parser.parse(response.body);
  return document.getElementsByClassName('views-row');
}

Future<FeedItem?> fetchNews(List<dom.Element> newsItems, int i) async {
  if (_hasNoMoreNews) return null;

  List<String> defaultTags = await extractFromFile("tags");
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

  var newsItem = newsItems[i];
  var titleElement =
      newsItem.querySelector('.views-field-title .field-content a');

  if (titleElement == null) return null;

  String txt =
      _firstTitleElement == null ? "placeholder" : _firstTitleElement.text;

  if (titleElement.text == txt) {
    _hasNoMoreNews = true;
    return null;
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

  final responseText = await http.get(Uri.parse(
      'https://www.fct.unl.pt' + (titleElement.attributes['href'] ?? '')));

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

    var feedItem = FeedItem(
      pageUrl:
          'https://www.fct.unl.pt' + (titleElement?.attributes['href'] ?? ''),
      content: summaryElement?.text,
      imageUrl: imageElement?.attributes['src'],
      likesCount: 0,
      commentsCount: 0,
      retweetsCount: 0,
      title: titleElement?.text,
      date: dateElement?.text,
      tags: tags,
    );

    return feedItem;
  }
  return null;
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
