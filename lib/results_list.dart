import 'package:flutter/material.dart';

import 'details.dart';
import 'classes/api.dart';

class ResultsList extends StatelessWidget {
  const ResultsList(this.title, this.results);

  final String title;
  final List<Map> results;

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.body2;

    List<Widget> children = [];
    for (int i = 0, len = results.length; i < len; i++) {
      var res = results[i];

      children.add(
        ListTile(
          title: Text(
            res['strMeal'],
            style: textStyle,
          ),
          onTap: () async {
            Map recipe = res.containsKey('strInstructions')
              ? res
              : (await Api.query('lookup', {'i': res['idMeal']}))['meals'][0];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Details(recipe)
              ),
           );
          },
        )
      );

      children.add(Divider(color: Colors.black));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: ListView(
          children: children,
        ),
      )
    );
  }
}