import 'package:flutter/cupertino.dart';
import 'package:flutter_typeahead/cupertino_flutter_typeahead.dart';

import 'data.dart';

class MyCupertinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'flutter_typeahead demo',
      home: CupertinoPageScaffold(
        child: FavoriteCitiesPage(),
      ), //MyHomePage(),
    );
  }
}

class FavoriteCitiesPage extends StatefulWidget {
  @override
  _FavoriteCitiesPage createState() => _FavoriteCitiesPage();
}

class _FavoriteCitiesPage extends State<FavoriteCitiesPage> {
  bool _progressBarActive = false;

  void loadDatabase() {
    setState(() {
      _progressBarActive = true;
    });

    suggestionService.init().whenComplete(() {
      setState(() {
        _progressBarActive = false;
      });
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  CupertinoSuggestionsBoxController _suggestionsBoxController =
      CupertinoSuggestionsBoxController();
  String favoriteCity = 'Unavailable';

  @override
  Widget build(BuildContext context) {
    return _progressBarActive == true
        ? Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(children: <Widget>[
            Text(
                "App parse 6mb file with english words and insert 400k rows in SQLite database"),
            Text("May take up to minute on first load"),
            CupertinoActivityIndicator(),
            Text(
                "Loading will be much faster for second load autcomplete run. App will just open database if it already exist and filled"),
            Text(
                "It possible to reduce load time by putting SQLite db file in app assests and just copy it instead of importing from .txt"),
            Text(
                "Replacing .txt file by sqlite db file will reduce first load to less than 1s"),
          ]),
        ))
        : Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: <Widget>[

                  SizedBox(
                    height: 100.0,
                  ),
                  CupertinoButton(
                    child: Text('Load autocomplete'),
                    onPressed: loadDatabase,
                  ),
                  Text('What is your favorite word?'),
                  CupertinoTypeAheadFormField(
                    getImmediateSuggestions: true,
                    suggestionsBoxController: _suggestionsBoxController,
                    textFieldConfiguration: CupertinoTextFieldConfiguration(
                      controller: _typeAheadController,
                    ),
                    suggestionsCallback: (pattern) {
                      return Future.delayed(
                        Duration(seconds: 1),
                        () => suggestionService.getSuggestions(pattern),
                      );
                    },
                    itemBuilder: (context, suggestion) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          suggestion,
                        ),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      _typeAheadController.text = suggestion;
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please select a word';
                      }
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  CupertinoButton(
                    child: Text('Submit'),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        setState(() {
                          favoriteCity = _typeAheadController.text;
                        });
                      }
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'Your favorite word is $favoriteCity!',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
  }
}
