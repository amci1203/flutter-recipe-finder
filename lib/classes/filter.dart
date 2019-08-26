import 'package:meta/meta.dart';
import 'api.dart';

class Filter {
  final String label;
  final String key;
  final List<String> options;

  const Filter({
    @required this.label,
    @required this.key,
    @required this.options,
  }):
    assert(label != null),
    assert(key != null),
    assert(options != null);

  Future<Map> lookup(option) async {
    var result = Api.query('filter', { key: option });
    return result;
  }
}