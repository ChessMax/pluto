class MapView {
  final Map<String, dynamic> _data;

  MapView(this._data);

  dynamic operator [](String key) => _data[key];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      final name = _symbolToString(invocation.memberName);
      if (_data.containsKey(name)) {
        final value = _data[name];
        if (value != null && value is Map<String, dynamic>) {
          return MapView(value);
        }

        return value;
      }
    }
    return super.noSuchMethod(invocation);
  }

  static String _symbolToString(Symbol symbol) {
    final s = symbol.toString();
    return s.substring(8, s.length - 2);
  }
}
