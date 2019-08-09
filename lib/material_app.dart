import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'data.dart';

class MyMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_typeahead demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FormExample(),
        ],
      ),
    );
  }
}

class FormExample extends StatefulWidget {
  @override
  _FormExampleState createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
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

  String _selectedWord;

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
            CircularProgressIndicator(),
            Text(
                "Loading will be much faster for second load autcomplete run. App will just open database if it already exist and filled"),
            Text(
                "It possible to reduce load time by putting SQLite db file in app assests and just copy it instead of importing from .txt"),
            Text(
                "Replacing .txt file by sqlite db file will reduce first load to less than 1s"),
          ]),
        ))
        : Form(
            key: this._formKey,
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    child: Text('Load autocomplete'),
                    onPressed: loadDatabase,
                  ),
                  Text('What is your favorite word?'),
                  TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(labelText: 'Word'),
                      controller: this._typeAheadController,
                    ),
                    suggestionsCallback: (pattern) async {
                      return await suggestionService.getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) {
                      this._typeAheadController.text = suggestion;
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please select a word';
                      }
                    },
                    onSaved: (value) => this._selectedWord = value,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  RaisedButton(
                    child: Text('Submit'),
                    onPressed: () {
                      if (this._formKey.currentState.validate()) {
                        this._formKey.currentState.save();
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Your Favorite Word is ${this._selectedWord}')));
                      }
                    },
                  )
                ],
              ),
            ),
          );
  }
}
