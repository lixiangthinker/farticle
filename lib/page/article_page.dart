import 'package:flutter/material.dart';
import 'package:fweather/model/article_model.dart';
import 'package:fweather/repo/article_repo.dart';
import 'package:fweather/utils/shared_pref_utils.dart' as sp;
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

  double _fontSize = 24;

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
            onTap: _handleGetYesterdayArticle,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.all_inclusive),
            title: Text('随机阅读', style: TextStyle(fontSize: 20),),
            onTap: _handleGetRandomArticle,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('我的收藏', style: TextStyle(fontSize: 20),),
            onTap: _handleMyStars,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('阅读设置', style: TextStyle(fontSize: 20),),
            onTap: _handleReadSettings,
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
          onPressed: _handleLike,
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _handleRefreshArticle,
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
          body: ArticleContent(article: snapshot.data, contentFontSize: _fontSize,),
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
    sp.getFontSize().then((value) {
      _fontSize = value;
    });
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
    Navigator.pop(context);
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
    Navigator.pop(context);
  }


  void _handleMyStars() async {
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

  void _handleReadSettings() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, mSetState) {
            return GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('字体大小'),
                        Expanded(
                            child: Slider(
                              onChanged: (value){
                                double valueRound = value.roundToDouble();
                                mSetState(
                                    () {
                                      _fontSize = valueRound;
                                    }
                                );
                                _onFontSliderChange(value);
                              },
                              onChangeEnd: (result){
                                print('Slider onChangeEnd $result');
                                sp.storeFontSize(result);
                              },
                              divisions: 24,
                              label: "${_fontSize.round()}",
                              value: _fontSize,
                              min: 12,
                              max: 36,
                            )),
                      ],
                    ),

                    Container(
                      height: 20,
                    )
                  ],
                ),
                height: 250,
                padding: EdgeInsets.all(10),
              ),
              onTap: () => false,
            );
          },
        );
      }
    );
  }

  void _onFontSliderChange(double value) {
    double valueRound = value.roundToDouble();
    setState(() {
      _fontSize = valueRound;
    });
  }
}

class ArticleContent extends StatefulWidget {
  final ArticleModel article;
  final double contentFontSize;

  ArticleContent({Key key, this.article, this.contentFontSize = 24}) : super(key: key);

  @override
  ArticleContentState createState() => ArticleContentState();
}

class ArticleContentState extends State<ArticleContent> {
  static const double CONTENT_FONT_SIZE_MAX = 36;
  static const double CONTENT_FONT_SIZE_MIN = 12;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(),
        child: Column(
          children: <Widget>[
            Text(
              widget.article.title,
              style: TextStyle(fontSize: 30),
            ),
            Text(
              widget.article.author,
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            Divider(),
            Text(
              widget.article.content,
              style: TextStyle(fontSize: widget.contentFontSize),
            ),
            Divider(),
            Text(
              "全文共 ${widget.article.wc.toString()} 字.",
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
