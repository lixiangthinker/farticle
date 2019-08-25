import 'package:flutter/material.dart';
import 'package:fweather/model/article_model.dart';
import 'package:fweather/repo/article_repo.dart';

import 'article_page.dart';

class StarListPage extends StatefulWidget {
  @override
  StarListPageState createState() => StarListPageState();
}

class StarListPageState extends State<StarListPage> {
  List<ArticleModel> starsList = [];
  Future<List<ArticleModel>> starsListFuture;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: starsListFuture,
      builder: _asyncContentBuilder,
    );
  }

  Widget _asyncContentBuilder(BuildContext context, AsyncSnapshot<List<ArticleModel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Scaffold(
          appBar: AppBar(),
          body: StarsListGetError(snapshot.error),
        );
      }
      starsList = snapshot.data;
      return Scaffold(
        appBar: _getAppBar(),
        body: StarsListContent(articleList: snapshot.data),
      );
    } else {
      return Scaffold(
        appBar: _getAppBar(),
        body: Center(child: CircularProgressIndicator(),),
      );
    }
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('我的收藏'),
      centerTitle: true,
    );
  }

  @override
  void initState() {
    print('StarListPageState initState()');
    starsListFuture = ArticleRepo.instance.getStaredArticle();
    super.initState();
  }
}

class StarsListGetError extends StatelessWidget {
  final error;

  StarsListGetError(this.error);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('Faile to get stared articles. \n${error.toString()}'));
  }
}

class StarsListContent extends StatelessWidget {

  final List<ArticleModel> articleList;

  StarsListContent({Key key, this.articleList}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: articleList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Text(articleList[index].author[0]),
          ),
          title: Text('${articleList[index].title}'),
          subtitle: _getSubTitleText(articleList[index].content),
          isThreeLine: true,
          trailing: Icon(Icons.star),
          onTap: (){
            Navigator.pop(context, articleList[index]);
          },
        );
      },
    );
  }

  static const int SUB_TITLE_LENGTH_MAX = 40;
  Widget _getSubTitleText(String content) {
    if (content == null) {
      return Text('');
    }

    String subTitle = content.trim();

    if (subTitle.length > SUB_TITLE_LENGTH_MAX) {
      return Text('${subTitle.substring(0,SUB_TITLE_LENGTH_MAX)}');
    } else {
      return Text('$subTitle');
    }
  }
}