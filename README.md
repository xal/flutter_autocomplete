# Flutter autcomplete sample. 

Simple app which show how to implement autocomplete for large amount of words (400k common english words in this example) in flutter for Android & iOS.

Key idea is **offline dropdown autocomplete** for common english words

<img src="./img/android.png " width="200"/>
<img src="./img/ios.png " width="200"/>


## How it works?

* SQlite database with 400k English words
* Import database data by clicking Load Autocomplete button. It loads words from `.txt` file from `assets` and execute 400k+ queries to import all word list
* Improting separated in transaction by `1000` queries to improve performance
* Load Autocomplete on seconds run (without import) take less than 1 seccond 
* Suggestion works by simple SQL query `"SELECT * FROM $table WHERE $wordColumnName like '$queryLowerCase%' LIMIT 10");` It is fast enough even for 400k rows database
* App uses `compute` to split large string var to avoid freezing during importig

## Limitations
* Import words to SQLite may take up to minute
* Words database for English 400k words size is 6MB
* `flutter_typeahead` Material widgets don't properly work on iOS. So App uses seperated widgets (Material & Cupertino) for Android & iOS.

## How to improve
* no copy-paste code
* BLoC arcitecture
* tests
* use same widgets for iOS & Android. New version of the lib can fix it. Also it is possible to use only different EditText Widget for different platforms instead of whole app windows for different OSs
* don't import words from `.txt`. It is possible to create sqlite database file and put it in `assets` folder instead of `.txt` and just copy to device instead of importing 400k queries. Unfortunatly, flutter don't support copy large files operation from assets for now. Better idea is use library [https://pub.dev/packages/large_file_copy](https://pub.dev/packages/large_file_copy) and put files in platform specific projects instead of `assets` folder
* Importing, copying and other heavy operations should be moved to background. Flutter support isolate not-in-main-thread operations via `compute` but it is not always possible to use it. Possible solutions is use platform specific background async API to improve FPS rate during heavy operations.


## Another ideas how to implement word sugestions for common words

- Neural networks is not good enough for text rigth now. Moreover networks should have own trained database, so simple SQLite database solution is more effecient, simple and easy-to-support for now
- Use Android & iOS spellchecking / autocomplete APIs. In this case we can remove own word listoffline database. We can use suggestion for any language installed on user device. Android has [SpellCheck API](https://android-developers.googleblog.com/2012/08/creating-your-own-spelling-checker.html) and UI elements with dropdown suggestions. iOS have only UI elements with dropdown suggestions and doesn't provide API to receive suggestions directly. So only one option is explore how UI elements works on both platforms and try reimplement it Flutter. As for me it is not good idea, because will take a lot of time and small benefit, perhaps it is even not possible.
- Flutter use softkeyboards for iOS & Android which have own suggestion UI, so dropdown not neccessary at all


## English word list source
`words_aplha.txt` from [https://github.com/dwyl/english-words
](https://github.com/dwyl/english-words)

## Dependencies 
* `flutter_typeahead`: ^`1.6.1`
* `sqflite`: ^`1.1.6`