import 'package:fweather/model/article_model.dart';
import 'package:fweather/utils/utils.dart' as utils;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'network_error.dart';

class OneArticleService {
  // https://interface.meiriyiwen.com/article/day?dev=1&date=20190609
  final String baseUrl = "https://interface.meiriyiwen.com";
  final String todayArticle = "/article/today?dev=1";
  final String randomArticle = "/article/random?dev=1";
  final String somedayArticle = "/article/day?dev=1&date=";

  // single instance
  factory OneArticleService() =>_getInstance();
  static OneArticleService get instance => _getInstance();
  static OneArticleService _instance;

  OneArticleService._internal() {
    // init network service here
  }

  static OneArticleService _getInstance() {
    if (_instance == null) {
      _instance = new OneArticleService._internal();
    }
    return _instance;
  }

  Future<ArticleModel> getArticle() async {
    print('OneArticleService getArticle');
    var client = http.Client();
    var response = await client.get(baseUrl + todayArticle);
    client.close();

    if (response.statusCode == 200) {
      return ArticleDataModel.fromJson(json.decode(response.body)).data;
    }
    return Future.error(NetworkError(response: response), StackTrace.current);
  }

  Future<ArticleModel> getArticleByDate(DateTime dateTime) async {
    print('OneArticleService getArticleByDate $dateTime');
    var day = utils.getDateString(dateTime);
    var client = http.Client();
    var response = await client.get(baseUrl + somedayArticle + day);
    client.close();

    if (response.statusCode == 200) {
      return ArticleDataModel.fromJson(json.decode(response.body)).data;
    }
    return Future.error(NetworkError(response: response), StackTrace.current);
  }

  Future<ArticleModel> getRandomArticle() async {
    print('OneArticleService getRandomArticle');
    var client = http.Client();
    var response = await client.get(baseUrl + randomArticle);
    client.close();

    if (response.statusCode == 200) {
      return ArticleDataModel.fromJson(json.decode(response.body)).data;
    }
    return Future.error(NetworkError(response: response), StackTrace.current);
  }
}