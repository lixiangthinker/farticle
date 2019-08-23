import 'package:fweather/db/one_article_db.dart';
import 'package:fweather/model/article_model.dart';
import 'package:fweather/net/one_article_service.dart';
import 'package:fweather/utils/utils.dart' as utils;

class ArticleRepo {
  Map<String, ArticleModel> _cache;
  OneArticleService articleService;
  OneArticleDb articleDb;
  ArticleRepo([this.articleService]){
    _cache = Map<String, ArticleModel>();
  }

  factory ArticleRepo.cached() {
    return ArticleRepo(OneArticleService());
  }

  Future<ArticleModel> getTodayArticle() async {
    print('ArticleRepo getTodayArticle');
    String key = utils.getDateString(DateTime.now());

    if (_cache.containsKey(key)) {
      print('ArticleRepo getTodayArticle from cache');
      return _cache[key];
    }

    try {
      ArticleModel articleModel = await articleService.getArticle();
      _cache[key] = articleModel;
      return articleModel;
    } catch (err) {
      return Future.error(err);
    }
  }
}