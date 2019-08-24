import 'package:flutter/material.dart';
import 'package:fweather/model/article_model.dart';
import 'package:fweather/repo/article_repo.dart';

class ArticlePage extends StatefulWidget {
  @override
  ArticlePageState createState() => ArticlePageState();
}

class ArticlePageState extends State<ArticlePage> {
  Future<ArticleModel> articleFuture;
  ArticleModel articleModel;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: articleFuture,
      builder: asyncContentBuilder,
    );
  }

  Widget getArticleTitle() {
    if (articleModel == null || articleModel.title == null) {
      return Text("Loading Article...");
    }
    return Text(articleModel.title);
  }

  Widget getAppBar() {
    return AppBar(
      title: getArticleTitle(),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon((articleModel == null || !articleModel.star)?Icons.star_border:Icons.star),
          onPressed: (){
            _handleLike();
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: (){
            _handleRefreshArticle();
          },
        ),
      ],
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
      articleModel = snapshot.data;
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
    articleFuture = ArticleRepo.instance.getTodayArticle();
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

  void _handleLike() {
    print('ArticlePageState _handleLike()');
    if (articleModel == null) return;
    setState(() {
      articleModel.star = !articleModel.star;
    });
    ArticleRepo.instance.updateArticle(articleModel);
  }

  void _handleRefreshArticle() {
    print('ArticlePageState _handleRefreshArticle()');
    setState(() {
      articleFuture = ArticleRepo.instance.getTodayArticle();
    });
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
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            Divider(),
            Text(
              article.content,
              style: TextStyle(fontSize: 24),
            ),
            Divider(),
            Text(
              "Total ${article.wc.toString()} words.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            )
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
