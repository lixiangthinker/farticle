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
    DateTime dateTime = DateTime.now();
    String key = utils.getDateString(dateTime);

    if (_cache.containsKey(key)) {
      print('ArticleRepo getTodayArticle from cache');
      return _cache[key];
    }

    try {
      ArticleModel articleModel =
          await _articleDb.getArticlesByDate(dateTime);
      if (articleModel != null) {
        _cache[key] = articleModel;
        return articleModel;
      }
    } catch (err) {
      return Future.error(err);
    }

    try {
      // api /article/today?dev=1 may have a different dateTime value. be careful.
      ArticleModel articleModel = await _articleService.getArticle();
      String newKey = articleModel.date.curr;

      if (newKey == key) {
        _articleDb.insertArticle(articleModel);
        _cache[key] = articleModel;
      } else {
        ArticleModel newkeyArticle =
        await _articleDb.getArticlesByDate(utils.getDateTimeFromString(newKey));
        if (newkeyArticle == null) {
          _articleDb.insertArticle(articleModel);
          _cache[key] = articleModel;
        } else {
          _cache[newKey] = newkeyArticle;
          return newkeyArticle;
        }
      }
      return articleModel;
    } catch (err) {
      return Future.error(err);
    }
  }

  Future<List<ArticleModel>> getStaredArticle() async {
    try {
      List<ArticleModel> articleModelList =
      await _articleDb.getStaredArticles();
      if (articleModelList != null) {
        return articleModelList;
      } else {
        return null;
      }
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
    print('ArticleRepo getArticleByDate $dateString');
    DateTime key = utils.getDateTimeFromString(dateString);

    if (_cache.containsKey(dateString)) {
      print('ArticleRepo getTodayArticle from cache');
      return _cache[dateString];
    }

    try {
      ArticleModel articleModel =
      await _articleDb.getArticlesByDate(key);
      if (articleModel != null) {
        _cache[dateString] = articleModel;
        return articleModel;
      }
    } catch (err) {
      return Future.error(err);
    }

    try {
      ArticleModel articleModel = await _articleService.getArticleByDate(key);
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
