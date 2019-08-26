import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:convert';

class Details extends StatefulWidget {
  final Map recipe;

  const Details(this.recipe, {
    Key key,
  }): assert(recipe != null);

  _State createState() => _State();
}

class _State extends State<Details> with SingleTickerProviderStateMixin {
  String _id;
  bool _isFavorite;
  TabController _tabController;

  final _tabs = [
    Tab(text: 'Ingredients'),
    Tab(text: 'Steps'),
    Tab(text: 'Details'),
  ];

  final _padding = EdgeInsets.symmetric(
    vertical: 12.0,
    horizontal: 16.0,
  );

  @override
  void initState() {
    super.initState();
    _id = widget.recipe['idMeal'];
    _tabController = TabController(
      vsync: this,
      length: _tabs.length
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    var isFav = await checkIfFavorite();
    setState(() {
      _isFavorite = isFav;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final screenHeight = dimensions.height;
    final screenWidth = dimensions.width;

    final imgHeight = screenWidth * 9.0 / 16.0;

    final r = widget.recipe;
    final title = r['strMeal'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            highlightColor: Colors.grey[900],
            icon: Icon(
              _isFavorite
                ? Icons.favorite
                : Icons.favorite_border,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: imgHeight
            ),
            child: Image.network(
              r['strMealThumb'],
              fit: BoxFit.cover,
              height: imgHeight,
            ),
          ),
          Container(
            color: Colors.black,
            child: Padding(
              padding: _padding,
              child: Text(
                title,
                style: Theme.of(context).textTheme.display1.apply(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          StickyHeader(
            header: Material(
              color: Colors.white,
              elevation: 2.0,
              child: TabBar(
                controller: _tabController,
                tabs: _tabs,
                indicatorColor: Colors.black,
                labelColor: Colors.black,
              ),
            ),
            content: Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 2,
              ),
              child: TabBarView(
                // physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  ingredientsTabView(r),
                  stepsTabView(r),
                  detailsTabView(r),
                ]
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8.0,
            ),
            child: Center(
              child: Text(
                "Nosey little bugger, aren't we?",
                textScaleFactor: 1.5,
                style: Theme.of(context).textTheme.body2.apply(
                  fontWeightDelta: 3,
                ),
              )
            ),
          ),
        ],
      )
    );
  }

  Widget ingredientsTabView(recipe) {
    final itemPadding = EdgeInsets.symmetric(vertical: 16.0);

    return Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: getIngredients(recipe).map((i) {
          return Padding(
            padding: itemPadding,
            child: Text(i),
          );
        }).toList(),
      ),
    );
  }

  Widget stepsTabView(recipe) {
    final itemPadding = EdgeInsets.only(bottom: 8.0);

    return Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: recipe['strInstructions'].split('\r\n').map<Widget>((i) {
          return Padding(
            padding: itemPadding,
            child: Text(i),
          );
        }).toList(),
      ),
    );
  }

  Widget detailsTabView(recipe) {
    return Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          createDetailCard('About', [
            ['Area', recipe['strArea']],
            ['Category', recipe['strCategory']],
          ]),
          createDetailCard('Resources', [
            ['Source', recipe['strSource']],
            ['YouTube', recipe['strYoutube']],
          ]),
        ],
      ),
    );
  }

  List<String> getIngredients(recipe) {
    var res = <String>[];
    for (var i = 1; i < 21; i++) {
      String ingredient = recipe['strIngredient$i'];
      if (ingredient == null || ingredient.length == 0) break;
      String amt = recipe['strMeasure$i'];
      res.add('$ingredient ($amt)');
    }
    return res;
  }
  Card createDetailCard(String heading, List tuplesList) {
    final itemPadding = EdgeInsets.symmetric(vertical: 8.0);

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          heading,
          style: Theme.of(context).textTheme.headline,
        ),
      )
    ];

    for (int i = 0, l = tuplesList.length; i < l; i++) {
      final tuple = tuplesList[i];
      if (tuple[1] == null) continue;

      children.add(Padding(
        padding: itemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: tuple[1].startsWith('http')
          ? [
            GestureDetector(
              onTap: () => launchUrl(tuple[1]),
              child: Text(
                tuple[0],
                style: TextStyle(
                  color: Colors.blue[500],
                ),
              ),
            ),
          ]
          : [
            Text(tuple[0]),
            Text(tuple[1])
          ]
        ),
      ));
    }

    return Card(
      child: Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Future<void> toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_isFavorite) {
      prefs.remove(_id);
    } else {
      prefs.setString(_id, jsonEncode(widget.recipe));
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<bool> checkIfFavorite() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_id);
  }

  Future<void> launchUrl(url) async {
    if (await canLaunch(url)) {
      print('>>>> Able to launch. Attempting to launch now...');
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}