import 'package:flutter/material.dart';

import 'details.dart';

class ResultsList extends StatelessWidget {
  const ResultsList(this.title, this.results);

  final String title;
  final List<Map> results;

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.body2;

    List<Widget> children = [];
    for (int i = 0, len = results.length; i < len; i++) {
      if (i > 0) children.add(Divider(color: Colors.black));

      children.add(
        ListTile(
          title: Text(
            results[i]['strMeal'],
            style: textStyle,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Details(results[i])
            ),
           ),
        )
      );
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