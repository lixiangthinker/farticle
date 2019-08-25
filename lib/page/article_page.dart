import 'package:flutter/material.dart';
import 'package:fweather/model/article_model.dart';
import 'package:fweather/page/star_list_page.dart';
import 'package:fweather/repo/article_repo.dart';
import 'package:fweather/utils/utils.dart' as utils;
import 'package:fweather/widget/left_drawer.dart';

class ArticlePage extends StatefulWidget {
  final ArticleModel article;

  ArticlePage({Key key, this.article}) : super(key: key);

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
      builder: _asyncContentBuilder,
    );
  }

  Widget _getArticleTitle() {
    if (articleModel == null || articleModel.title == null) {
      return Text("Loading Article...");
    }
    return Text(utils.formatTitleString(articleModel.date.curr));
  }

  Widget _getDrawer() {
    return LeftDrawer(
      widthPercent: 0.6,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('每日一文', style: TextStyle(fontSize: 32, color: Colors.white),
                )),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.reply),
            title: Text('昨日重现', style: TextStyle(fontSize: 20),),
            onTap: () {
              _handleGetYesterdayArticle();
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.all_inclusive),
            title: Text('随机阅读', style: TextStyle(fontSize: 20),),
            onTap: () {
              _handleGetRandomArticle();
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('我的收藏', style: TextStyle(fontSize: 20),),
            onTap: () {
              _handleOnTap();
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('阅读设置', style: TextStyle(fontSize: 20),),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: _getArticleTitle(),
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

  Widget _asyncContentBuilder(BuildContext context, AsyncSnapshot<ArticleModel> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Scaffold(
          appBar: _getAppBar(),
          body: ArticleGetError(snapshot.error),
          drawer: _getDrawer(),
        );
      }
      articleModel = snapshot.data;
      return Scaffold(
          appBar: _getAppBar(),
          body: ArticleContent(article: snapshot.data),
          drawer: _getDrawer(),
      );
    } else {
      return Scaffold(
          appBar: _getAppBar(),
          body: Center(child: CircularProgressIndicator(),),
          drawer: _getDrawer(),
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
    if (articleModel == null) {
      setState(() {
        articleFuture = ArticleRepo.instance.getTodayArticle();
      });
    } else {
      setState(() {
        articleFuture = ArticleRepo.instance.getArticleByDate(articleModel.date.curr);
      });
    }
  }

  void _handleGetRandomArticle() {
    print('ArticlePageState _handleGetRandomArticle()');
    if (articleModel == null) {
      setState(() {
        articleFuture = ArticleRepo.instance.getTodayArticle();
      });
    } else {
      setState(() {
        articleFuture = ArticleRepo.instance.getRandomArticle();
      });
    }
  }

  void _handleGetYesterdayArticle() {
    print('ArticlePageState _handleGetYesterdayArticle()');
    if (articleModel == null) {
      setState(() {
        articleFuture = ArticleRepo.instance.getTodayArticle();
      });
    } else {
      setState(() {
        articleFuture = ArticleRepo.instance.getArticleByDate(articleModel.date.prev);
      });
    }
  }


  void _handleOnTap() async {
    var result = await Navigator.pushNamed(context, "/stars");
    print("result = $result");
    Navigator.pop(context);
    if (result == null) {
      setState(() {
        articleFuture = ArticleRepo.instance.getTodayArticle();
      });
    } else {
      setState(() {
        articleFuture = ArticleRepo.instance.getArticleByDate((result as ArticleModel).date.curr);
      });
    }
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
              "全文共 ${article.wc.toString()} 字.",
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
