import 'package:flutter/material.dart';
import 'package:fweather/model/article_model.dart';
import 'package:fweather/repo/article_repo.dart';

class ArticlePage extends StatefulWidget {
  ArticleModel article;

  ArticlePage({Key key, this.article}) : super(key: key);

  @override
  ArticlePageState createState() => ArticlePageState();
}

class ArticlePageState extends State<ArticlePage> {
  Future<ArticleModel> articleFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: articleFuture,
      builder: asyncContentBuilder,
    );
  }

  Widget getArticleTitle() {
    if (widget.article == null || widget.article.title == null) {
      return Center(child: Text("Loading Article..."));
    }
    return Center(child: Text(widget.article.title));
  }

  Widget getAppBar() {
    return AppBar(
      title: getArticleTitle(),
    );
  }

  Widget asyncContentBuilder(BuildContext context, AsyncSnapshot<ArticleModel> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Scaffold(
        appBar: getAppBar(),
          body: ArticleGetError(snapshot.error),
        );
      }
      widget.article = snapshot.data;
      return Scaffold(
          appBar: getAppBar(),
          body: ArticleContent(article: snapshot.data));
    } else {
      return Scaffold(
          appBar: getAppBar(),
          body: Center(child: CircularProgressIndicator())
      );
    }
  }

  @override
  void initState() {
    print('ArticlePageState initState()');
    articleFuture = ArticleRepo().getTodayArticle();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    print('ArticlePageState didChangeDependencies()');
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    print('ArticlePageState dispose()');
    super.dispose();
  }
}

class ArticleContent extends StatelessWidget {
  final ArticleModel article;

  ArticleContent({Key key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(),
        child: Column(
          children: <Widget>[
            Text(
              article.title,
              style: TextStyle(fontSize: 30),
            ),
            Text(
              article.author,
              style: TextStyle(fontSize: 24),
            ),
            Text(
              article.content,
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleGetError extends StatelessWidget {
  final error;

  ArticleGetError(this.error);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('Faile to get articles for today. \n${error.toString()}'));
  }
}
