import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import 'details.dart';

class FavoritesList extends StatefulWidget {
  const FavoritesList();
  _State createState() => _State();
}

class _State extends State<FavoritesList> {
  final _globalKey = GlobalKey<ScaffoldState>();
  final _timeout = Duration(seconds: 7);

  List<Map> _favorites = [];
  bool _loaded = false;
  Timer _deleteTimer;
  String _markedId;


  final _appBar = AppBar(
    title: Text('Favorites'),
    backgroundColor: Colors.black,
  );

  @override
  Future<void> dispose() async {
    if (_deleteTimer.isActive) _deleteTimer.cancel();
    if (_markedId != null) await removeMarkedId();

    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    var prefs = await SharedPreferences.getInstance();
    var keys = prefs.getKeys();
    if (keys.isEmpty) {
      setState(() {
        _loaded = true;
      });
    }

    setState(() {
      _favorites = keys.map<Map>((key) {
        return jsonDecode(prefs.getString(key));
      }).toList()
        ..sort((a, b) => a['strMeal'].compareTo(b['strMeal']));

      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_favorites.isEmpty) {
      return emptyScaffold(_loaded);
    }

    var textStyle = Theme.of(context).textTheme.body2;

    List<Widget> children = [];
    for (int i = 0, len = _favorites.length; i < len; i++) {
      var curr = _favorites[i];

      if (curr['__deleted'] != true) {
        children.add(
          ListTile(
            title:  Text(
              _favorites[i]['strMeal'],
              style: textStyle,
            ),
            onTap: () => pushDetailsRoute(curr),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.black,
              ),
              onPressed: () => markAsDeleted(curr, i),
            ),
          )
        );

        children.add(
          Divider(
            color: Colors.black
          )
        );
      }
    }

    return Scaffold(
      key: _globalKey,
      appBar: _appBar,
      body: Container(
        alignment: Alignment.topCenter,
        child: ListView(
          children: children,
        ),
      )
    );
  }

  void pushDetailsRoute(Map recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Details(recipe)
      ),
    );
  }

  Future<void> removeMarkedId() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove(_markedId);
  }

  Future<void> markAsDeleted(Map fav, int index) async {
    if (_markedId != null) await removeMarkedId();

    var key = fav['idMeal'];
    _markedId = key;
    // Start Timer
    final timer = Timer(_timeout, () {
      removeMarkedId();
      setState(() {
        _favorites.removeAt(index);
      });
    });

    setState(() {
      _favorites[index]['__deleted'] = true;
    });

    final snackbar = SnackBar(
      content: Text(
        "Removed ${fav['strMeal']}",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      duration: _timeout,
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          timer.cancel();
          setState(() {
            _favorites[index].remove('__deleted');
          });
        },
      ),
    );

    _globalKey.currentState.showSnackBar(snackbar);
  }

  Widget emptyScaffold(bool _loaded) {
    return Scaffold(
      appBar: _appBar,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: Center(
          child: _loaded
            ? Text(
              'No Favorites Yet :(',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            )
            : CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.black),
              backgroundColor: Colors.white,
            ),
        ),
      ),
    );
  }
}