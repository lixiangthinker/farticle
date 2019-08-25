import 'package:flutter/material.dart';
import 'package:fweather/page/article_page.dart';
import 'package:fweather/page/star_list_page.dart';

void main() => runApp(OneArticleApp());

class OneArticleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Article Each Day',
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/' : (_) => ArticlePage(),
        '/stars': (_) => StarListPage(),
      },
    );
  }
}
