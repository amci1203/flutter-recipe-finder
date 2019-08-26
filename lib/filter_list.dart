import 'package:flutter/material.dart';

import 'classes/api.dart';
import 'results_list.dart';

class FilterList extends StatefulWidget {
  final String path;  // Path used by API
  final String query; // Query param used by API
  final String label; // Filter name used to create AppBar title
  final List<String> options; // List of options
  final int columns; // Number of Columns A Row

  FilterList(
    this.label,
    this.path,
    this.query,
    this.options,
    this.columns,
    { Key key }
  ): super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<FilterList> {
  final api = Api();
  final _globalKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];
    List<Widget> items = widget.options.map((val) => option(val)).toList();

    stack.add(
      GridView.count(
        padding: EdgeInsets.all(8.0),
        crossAxisCount: widget.columns,
        childAspectRatio: widget.columns > 3 ? 2.0 : 3.0,
        children: items,
      )
    );

    if (_loading) stack.add(
      Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white70,
        ),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.black),
          backgroundColor: Colors.white30,
        )
      )
    );

    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text('Select A ${widget.label}'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: stack,
      )
    );
  }

  Future<void> getResults(String option) async {
    setState(() {
      _loading = true;
    });
    var json = await Api.query(widget.path, { widget.query: option.replaceAll(' ', '_')});
    var results = List<Map>.from(json['meals']);
    var empty = results == null;
    
    setState(() {
      _loading = false;
    });

    if (empty) {
      _globalKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.black,
        content: Text('No results found for that option'),
      ));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsList('${widget.label}: $option', results),
      ),
    );
  }

  Widget option(String text) {
    return  Container(
        margin: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0
          ),
        ),
        child: FlatButton(
          onPressed: () => getResults(text),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.body2,
            ),
          ),
        ),
    );
  }
}