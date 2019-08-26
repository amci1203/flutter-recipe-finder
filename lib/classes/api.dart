import 'package:flutter/services.dart' show rootBundle;

import 'dart:io';
import 'dart:async';
import 'dart:convert' show json, utf8;

final apiTxt = 'assets/keys/api.txt';

class Api {
  static final http     = HttpClient();
  static final domain   = 'www.themealdb.com';
  static final basePath = '/api/json/v1';
  static final cache    = Map();

  static Future query(String path, [ Map<String, String> where ]) async {
    String key = cache['API_KEY'];
    if (key == null) {
      key = await rootBundle.loadString(apiTxt);
      cache['API_KEY'] = key;
    }

    final uri = Uri.https(domain, '$basePath/$key/$path.php', where);
    if (path != 'random' && cache.containsKey(uri)) {
      return cache[uri];
    }

    try {
      final req = await http.getUrl(uri);
      final res = await req.close();

      if (res.statusCode != HttpStatus.ok) return null;

      final body = await res.transform(utf8.decoder).join();
      final map  = json.decode(body);

      cache[uri] = map;
      return map;
    } on Exception catch(e) {
      print('Unable to fetch the requested URI "${uri.toString()}"');
      print('Reason: $e');
      return null;
    }
  }
}