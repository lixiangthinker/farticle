import 'package:fweather/db/one_article_db.dart';
import 'package:fweather/model/article_model.dart';
import 'package:fweather/net/one_article_service.dart';
import 'package:fweather/utils/utils.dart' as utils;

class ArticleRepo {
  Map<String, ArticleModel> _cache;
  OneArticleService articleService;
  OneArticleDb articleDb;

  // single instance
  factory ArticleRepo() =>_getInstance();
  static ArticleRepo get instance => _getInstance();
  static ArticleRepo _instance;

  static ArticleRepo _getInstance() {
    if (_instance == null) {
      _instance = new ArticleRepo._internal();
    }
    return _instance;
  }

  ArticleRepo._internal() {
    _cache = Map<String, ArticleModel>();
    articleService = OneArticleService();
    articleDb = OneArticleDb();
  }

  Future<ArticleModel> getTodayArticle() async {
    print('ArticleRepo getTodayArticle');
    String key = utils.getDateString(DateTime.now());

    if (_cache.containsKey(key)) {
      print('ArticleRepo getTodayArticle from cache');
      return _cache[key];
    }

    try {
      ArticleModel articleModel = await articleDb.getArticlesByDate(DateTime.now());
      if (articleModel != null) {
        _cache[key] = articleModel;
        return articleModel;
      }
    } catch (err) {
      return Future.error(err);
    }

    try {
      ArticleModel articleModel = await articleService.getArticle();
      articleDb.insertArticle(articleModel);
      _cache[key] = articleModel;
      return articleModel;
    } catch (err) {
      return Future.error(err);
    }
  }
}