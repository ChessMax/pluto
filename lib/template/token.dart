import 'package:equatable/equatable.dart';

enum TokenType {
  at,
  dot,
  identifier,
  literal,
  lt,
  gt,
  slash,
  openParen,
  closeParen,
  eof;

  const TokenType();
}

class Token extends Equatable {
  final TokenType type;
  final Object? value;

  Token({required this.type, this.value});

  @override
  List<Object?> get props => [type, value];

  String get identifier => value as String;
}