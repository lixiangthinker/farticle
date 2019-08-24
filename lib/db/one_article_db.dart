import 'dart:async';

import 'package:fweather/model/article_model.dart';
import 'package:fweather/utils/utils.dart' as utils;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OneArticleDb {
  // single instance
  factory OneArticleDb() => _getInstance();

  static OneArticleDb get instance => _getInstance();
  static OneArticleDb _instance;

  OneArticleDb._internal() {
    // init db service here
  }

  static OneArticleDb _getInstance() {
    if (_instance == null) {
      _instance = new OneArticleDb._internal();
    }
    return _instance;
  }

  static const int DB_VERSION = 1;
  static const String TABLE_NAME = "articles";
  static const String COLUMN_ID = "id";
  static const String COLUMN_DATE_CURR = "date_curr";
  static const String COLUMN_DATE_PREV = "date_prev";
  static const String COLUMN_DATE_NEXT = "date_next";
  static const String COLUMN_AUTHOR = "author";
  static const String COLUMN_DIGEST = "digest";
  static const String COLUMN_TITLE = "title";
  static const String COLUMN_CONTENT = "content";
  static const String COLUMN_STAR = "star";
  static const String COLUMN_WORD_COUNT = "wc";

  Future<Database> _openDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'one_article_database.db'),
      // When the database is first created, create a table to store articles.
      onCreate: (db, version) {
        return db.execute(
          """CREATE TABLE $TABLE_NAME (
            $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COLUMN_DATE_CURR TEXT NULL UNIQUE,
            $COLUMN_DATE_PREV TEXT NULL,
            $COLUMN_DATE_NEXT TEXT NULL,
            $COLUMN_AUTHOR TEXT NULL,
            $COLUMN_DIGEST TEXT NULL,
            $COLUMN_TITLE TEXT NULL,
            $COLUMN_CONTENT TEXT NULL,
            $COLUMN_STAR INTEGER,
            $COLUMN_WORD_COUNT INTEGER
          )""",
        );
      },
      version: DB_VERSION,
    );
  }

  Future<void> insertArticle(ArticleModel articleModel) async {
    print(
        'OneArticleDb insertArticle articleModel curr = ${articleModel.date.curr}');
    // Get a reference to the database.
    final Database db = await _openDatabase();

    // Insert the ArticleModel into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    int result = await db.insert(
      TABLE_NAME,
      articleModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('OneArticleDb insertArticle result = $result');
  }

  Future<List<ArticleModel>> articles() async {
    print('OneArticleDb articles');
    // Get a reference to the database.
    final Database db = await _openDatabase();

    // Query the table for all The articles.
    final List<Map<String, dynamic>> maps = await db.query(TABLE_NAME);

    // Convert the List<Map<String, dynamic> into a List<ArticleModel>.
    return List.generate(maps.length, (i) {
      var date = ArticleDate(
        curr: maps[i]['date_curr'],
        prev: maps[i]['date_prev'],
        next: maps[i]['date_next'],
      );
      return ArticleModel(
        date: date,
        author: maps[i]['author'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        wc: maps[i]['wc'],
        digest: maps[i]['digest'],
        star: maps[i]['star'],
      );
    });
  }

  Future<ArticleModel> getArticlesByDate(DateTime dateTime) async {
    print('OneArticleDb getArticlesByDate dateTime = $dateTime');
    // Get a reference to the database.
    final Database db = await _openDatabase();
    var curr = utils.getDateString(dateTime);
    // Query the table for all The articles.
    final List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME,
      where: "date_curr=?",
      whereArgs: ['$curr'],
    );
    //final List<Map<String, dynamic>> maps = await db.rawQuery("SELECT * FROM $TABLE_NAME WHERE date_curr=?", ['$curr']);
    print('OneArticleDb getArticlesByDate map = $maps');
    if (maps.length == 0) {
      return null;
    }

    // Convert the List<Map<String, dynamic> into a List<ArticleModel>.
    return List.generate(maps.length, (i) {
      var date = ArticleDate(
        curr: maps[i]['date_curr'],
        prev: maps[i]['date_prev'],
        next: maps[i]['date_next'],
      );
      return ArticleModel(
        date: date,
        author: maps[i]['author'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        wc: maps[i]['wc'],
        digest: maps[i]['digest'],
        star: maps[i]['star']==1,
      );
    })[0];
  }

  Future<void> updateArticle(ArticleModel articleModel) async {
    print('OneArticleDb updateArticle curr = ${articleModel.date.curr}, star = ${articleModel.star}');
    // Get a reference to the database.
    final Database db = await _openDatabase();

    // Update the given Dog.
    await db.update(
      TABLE_NAME,
      articleModel.toMap(),
      // Ensure that the Dog has a matching id.
      where: "date_curr = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [articleModel.date.curr],
    );
  }
}
