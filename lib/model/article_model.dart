import 'dart:convert';
//import 'package:http/http.dart' as http;

class ArticleDataModel {
  final data;

  ArticleDataModel({this.data});

  factory ArticleDataModel.fromJson(Map<String, dynamic> json) {
    return ArticleDataModel(
      data: ArticleModel.fromJson(json['data']),
    );
  }

  @override
  String toString() {
    return '{data:$data}';
  }
}

class ArticleModel {
  final date;
  final author;
  final title;
  final digest;
  final content;
  final wc;

  ArticleModel(
      {this.date, this.author, this.title, this.digest, this.content, this.wc});

  factory ArticleModel.fromJson(Map<String, dynamic> json) {

    String parsedContent = _stripPTag(json['content']);

    return ArticleModel(
      date: ArticleDate.fromJson(json['date']),
      author: json['author'],
      title: json['title'],
      digest: json['digest'],
      content: parsedContent,
      wc: json['wc'],
    );
  }

  static String _stripPTag(String content) {
    String result = content?.replaceAll("<p>", "        ");
    result = result?.replaceAll("</p>", "\n");
    return result;
  }

  @override
  String toString() {
    return '{date:$date, author:$author, title:$title, digest:$digest, content:$content, wc:$wc}';
  }
}

class ArticleDate {
  final String curr;
  final String prev;
  final String next;

  ArticleDate({this.curr, this.prev, this.next});

  factory ArticleDate.fromJson(Map<String, dynamic> json) {
    return ArticleDate(
      curr: json['curr'],
      prev: json['prev'],
      next: json['next'],
    );
  }

  @override
  String toString() {
    return '{curr:$curr, prev,$prev, next,$next}';
  }
}

void main() async {
//  var client = http.Client();
//  final response =
//      await client.get('https://interface.meiriyiwen.com/article/day?dev=1&date=20190609');
//  Map<String, dynamic> decoded = json.decode(response.body);
//  print(decoded.runtimeType);
//
//  ArticleDataModel model = ArticleDataModel.fromJson(decoded);
//  print(model);
//  var encoded = json.encode(model);
//  print(encoded);

    String listJson = '{"city": "Mumbai","streets":["address1","address2"]}';

    var decoded = json.decode(listJson);
    print(decoded.runtimeType);
    print(decoded);
    var streets = decoded['streets'].map((address) => address + 'converted').toList();
    var listStreets = List<String>.from(streets);
    print(listStreets.runtimeType);
    print(listStreets);
}
