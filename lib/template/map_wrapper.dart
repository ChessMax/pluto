class MapView {
  final Map<String, dynamic> _data;

  MapView(this._data);

  dynamic operator [](String key) => _data[key];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      final name = _symbolToString(invocation.memberName);
      if (_data.containsKey(name)) return _data[name];
    }
    return super.noSuchMethod(invocation);
  }

  static String _symbolToString(Symbol symbol) {
    final s = symbol.toString();
    return s.substring(8, s.length - 2);
  }
}