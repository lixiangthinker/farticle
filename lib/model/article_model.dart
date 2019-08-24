import 'dart:convert';

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
  final ArticleDate date;
  final String author;
  final String title;
  final String digest;
  final String content;
  final int wc;
  bool star;

  ArticleModel(
      {this.date, this.author, this.title, this.digest, this.content, this.wc, this.star = false});

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
    return '{date:$date, author:$author, title:$title, digest:$digest, content:$content, wc:$wc, star:$star}';
  }

  Map<String, dynamic> toMap() {
    return {
      "date_curr":date.curr,
      "date_prev":date.prev,
      "date_next":date.next,
      "author":author,
      "title":title,
      "digest":digest,
      "content":content,
      "wc":wc,
      "star":star?1:0,
    };
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
