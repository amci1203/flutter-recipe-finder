import 'package:flutter/material.dart';
import 'dart:convert';

import 'details.dart';
import 'favorites_list.dart';
import 'filter_list.dart';
import 'classes/api.dart';

class Homepage extends StatefulWidget {
  const Homepage();
  _State createState() => _State();
}

class _State extends State<Homepage> {
  List<String> _categories;
  List<String> _areas;
  List<String> _ingredients;

  bool _loaded = false;

  final _letters = 'ABCDEFGHIJKLMNOPQRSTUVQRSTUVWXYZ'.split('');
  final _padding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 4.0,
  );

  final _halfPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 4.0,
  );
  
  final buttonHeight = 60.0;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_loaded) return;

    final jsonPath = 'assets/data/filter_options.json';
    final jsonString = await DefaultAssetBundle.of(context).loadString(jsonPath);
    final json = jsonDecode(jsonString);
    if (json is! Map) throw ('Data retrieved from API is not a Map; how df...');

    setState(() {
      _areas = List<String>.from(json['Areas']);
      _categories = List<String>.from(json['Categories'].map((m) => m['label']));
      _ingredients = List<String>.from(json['Ingredients'].map((m) => m['label']));
      _loaded = true;
    });
  }

  Future<void> pushRandomView(BuildContext context) async {
    // setLoading(true);
    var result = await Api.query('random');
    var recipe = result['meals'][0];
    // setLoading(false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Details(recipe)
      ),
    );
  }

  void pushFavoritesRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesList()
      )
    );
  }

  void pushFilterListRoute(label, path, query, options, numRows) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterList(label, path, query, options, numRows)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipe Finder',
          style: TextStyle(
            color: Colors.white
          )
        ),
        backgroundColor: Colors.black,
      ),
      body: _loaded
        ? selectOptions(context)
        : Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.black),
          )
        ),
    );
  }

  Widget selectOptions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 36.0),
            child: Center(
              child: Text(
                'SEARCH BY',
                // textScaleFactor: 2.0,
                style: Theme.of(context).textTheme.display2,
              ),
            ),
          ),
          option('Random', Icons.cached, () async => pushRandomView(context)),
          option('Letter', Icons.font_download, () {
            pushFilterListRoute('Letter', 'search', 'f', _letters, 4);
          }),
          option('Area', Icons.map, () {
            pushFilterListRoute('Area', 'filter', 'a', _areas, 2);
          }),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(right: 4.0),
                  child: option('Category', Icons.category, () {
                    pushFilterListRoute('Category', 'filter', 'c', _categories, 2);
                  }, true),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 4.0),
                  child: option('Ingredient', Icons.restaurant, () {
                    pushFilterListRoute('Ingredient', 'filter', 'i', _ingredients, 2);
                  }, true)
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: option('Favorites', Icons.favorite, () => pushFavoritesRoute(context))
          )
        ],
      ),
    );
  }

  Widget option(String text, IconData icon, Function onTap, [bool isHalfSize = false]) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: buttonHeight,
        margin: EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 3.0
          ),
        ),
        child: InkWell(
          highlightColor: Colors.black,
          splashColor: Colors.black,
          onTap: onTap,
          child: Padding(
            padding: isHalfSize ? _halfPadding : _padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  text.toUpperCase(),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                Icon(
                  icon,
                  size: 36.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
      )
      ),
    );
  }
}