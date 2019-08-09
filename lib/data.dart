import 'dart:async';
import 'dart:async' show Future;
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

List<String> splitAsync(String data) {
  return data.split("\n");
}

BackendService suggestionService = BackendService();

class BackendService {
  var dbName = "en20.db";
  String table = "words";
  var wordColumnName = "word";

  Database db;

  Future init() async {
    var path = await calculateDatabasePath(dbName);

    // make sure the folder exists
    if (!await Directory(dirname(path)).exists()) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print(e);
      }
    }

    var alreadyExist = await File(path).exists();

    db = await openDatabase(path);

    if (!alreadyExist) {
      await db.execute(
          "CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT)");

      // should be buffered reader
      var data = await rootBundle.loadString(
          "assets/wordlist/en.txt", cache: false);


      // heavy operation because data size is 6MB
      var lines = await compute(splitAsync, data);

      // make transaction with 100 queries to avoid frame loss
      var rowsPerTransaction = 1000;
      for (int i = 0; i < lines.length; i += rowsPerTransaction) {
        await db.transaction((Transaction txn) {
          for (int j = 0; j < rowsPerTransaction; j++) {
            var index = i + j;
            if(index >= lines.length) break;
            var line = lines[index];
            txn.execute(
                "INSERT INTO $table ($wordColumnName) VALUES ('$line')");
          }
        }
        );
      }

      await db.transaction((Transaction txn) {
        lines.forEach(((String line) {
          txn.execute(
              "INSERT INTO $table ($wordColumnName) VALUES ('$line')");
        }));
      });
    }
  }

  Future finish() async {
    db.close();
  }

  Future<List> getSuggestions(String query) async {
    if (db == null) {
      return List();
    }
    var queryLowerCase = query.toLowerCase();

    var result = await db.rawQuery(
        "SELECT * FROM $table WHERE $wordColumnName like '$queryLowerCase%' LIMIT 10");

    List<String> matches = List();

    matches.addAll(result.map((Map<String, dynamic> row) {
      return row[wordColumnName];
    }));

    return matches;
  }
}

Future<String> calculateDatabasePath(String dbName) async {
  final String databasePath = await getDatabasesPath();

  final String path = join(databasePath, dbName);

  return path;
}
