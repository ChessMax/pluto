import 'dart:convert';

extension StringExtensions on String {
  List<String> splitByLines() {
    final lines = const LineSplitter().convert(this);
    return lines;
  }
}