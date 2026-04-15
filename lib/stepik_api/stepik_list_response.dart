import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/json.dart';
import 'package:pluto/data/meta_dto.dart';

class GStepikListResponse<T> {
  final MetaDto? meta;
  final List<T> items;

  GStepikListResponse({this.meta, required this.items});

  T get firstItem => items.first;
}