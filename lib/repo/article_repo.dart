import 'package:fweather/db/one_article_db.dart';
import 'package:fweather/model/article_model.dart';
import 'package:fweather/net/one_article_service.dart';
import 'package:fweather/utils/utils.dart' as utils;

class ArticleRepo {
  Map<String, ArticleModel> _cache;
  OneArticleService _articleService;
  OneArticleDb _articleDb;

  // single instance
  factory ArticleRepo() => _getInstance();

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
    _articleService = OneArticleService();
    _articleDb = OneArticleDb();
  }

  Future<ArticleModel> getTodayArticle() async {
    print('ArticleRepo getTodayArticle');
    String key = utils.getDateString(DateTime.now());

    if (_cache.containsKey(key)) {
      print('ArticleRepo getTodayArticle from cache');
      return _cache[key];
    }

    try {
      ArticleModel articleModel =
          await _articleDb.getArticlesByDate(DateTime.now());
      if (articleModel != null) {
        _cache[key] = articleModel;
        return articleModel;
      }
    } catch (err) {
      return Future.error(err);
    }

    try {
      ArticleModel articleModel = await _articleService.getArticle();
      _articleDb.insertArticle(articleModel);
      _cache[key] = articleModel;
      return articleModel;
    } catch (err) {
      return Future.error(err);
    }
  }

  Future<ArticleModel> getRandomArticle() async {
    print('ArticleRepo getRandomArticle');

    try {
      ArticleModel articleModel = await _articleService.getRandomArticle();
      _articleDb.insertArticle(articleModel);
      _cache[articleModel.date.curr] = articleModel;
      return articleModel;
    } catch (err) {
      return Future.error(err);
    }
  }

  Future<ArticleModel> getArticleByDate(String dateString) async {
    print('ArticleRepo getArticleByDate');
    DateTime dateTime = utils.getDateTimeFromString(dateString);

    try {
      ArticleModel articleModel = await _articleService.getArticleByDate(dateTime);
      _articleDb.insertArticle(articleModel);
      _cache[articleModel.date.curr] = articleModel;
      return articleModel;
    } catch (err) {
      return Future.error(err);
    }
  }

  Future<void> updateArticle(ArticleModel articleModel) async {
    print('ArticleRepo updateArticle curr = ${articleModel.date.curr} '
        'star = ${articleModel.star}');
    _cache[articleModel.date.curr] = articleModel;
    try {
      await _articleDb.updateArticle(articleModel);
    } catch (err) {
      return Future.error(err);
    }
  }
}
