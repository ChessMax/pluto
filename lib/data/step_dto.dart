import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/json.dart';

part 'step_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class StepDto {
  final int id;
  final int lesson;
  final int position;

  // "preparing"
  final String status;
  final BlockDto block;

  // "actions": {
  // "comment": "#"
  // },
  // "77-9475928",
  final String progress;

  // [
  // "31-77-9475928",
  // "30-77-9475928"
  // ]
  final List<String> subscriptions;
  final dynamic? instruction;
  final dynamic? session;
  final dynamic instructionType;
  final int viewedBy;
  final int passedBy;
  final dynamic? correctRatio;
  final int worth;
  final bool isSolutionsUnlocked;
  final int solutionsUnlockedAttempts;
  final bool hasSubmissionsRestrictions;
  final int maxSubmissionsCount;
  final int variation;
  final int variationsCount;
  final bool isEnabled;
  final dynamic? needsPlan;

  // [0, 0, 0, 0, 0]
  final List<int> numGrades;
  final dynamic? userStepGrade;
  final dynamic? userStepVote;

  // "2026-02-05T14:35:42.368Z",
  final String createDate;
  final String updateDate;
  final int discussionsCount;

  // "77-9475928-1"
  final String discussionProxy;

  // [
  // "77-9475928-1"
  // ],
  final List<String> discussionThreads;
  final String reasonOfFailure;
  final ErrorDto error;
  final List<dynamic> warnings;
  final int cost;

  const StepDto({
    required this.id,
    required this.lesson,
    required this.position,
    required this.status,
    required this.block,
    required this.progress,
    required this.subscriptions,
    this.instruction,
    this.session,
    this.instructionType,
    this.viewedBy = 0,
    this.passedBy = 0,
    this.correctRatio,
    this.worth = 0,
    required this.isSolutionsUnlocked,
    required this.solutionsUnlockedAttempts,
    required this.hasSubmissionsRestrictions,
    required this.maxSubmissionsCount,
    required this.variation,
    required this.variationsCount,
    required this.isEnabled,
    this.needsPlan,
    required this.numGrades,
    this.userStepGrade,
    this.userStepVote,
    required this.createDate,
    required this.updateDate,
    required this.discussionsCount,
    required this.discussionProxy,
    required this.discussionThreads,
    required this.reasonOfFailure,
    required this.error,
    required this.warnings,
    required this.cost,
  });

  static StepDto fromJson(JsonObject value) => _$StepDtoFromJson(value);

  JsonObject toJson() => _$StepDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BlockDto {
  final String name;
  final String text;
  final String? video;
  final dynamic options;
  final List<dynamic> subtitleFiles;
  final bool isDeprecated;
  final dynamic source;
  final dynamic subtitles;
  final dynamic? testsArchive;
  final String feedbackCorrect;
  final String feedbackWrong;

  BlockDto({
    required this.name,
    required this.text,
    required this.video,
    required this.options,
    required this.subtitleFiles,
    required this.isDeprecated,
    required this.source,
    required this.subtitles,
    required this.testsArchive,
    required this.feedbackCorrect,
    required this.feedbackWrong,
  });

  static BlockDto fromJson(JsonObject value) => _$BlockDtoFromJson(value);

  JsonObject toJson() => _$BlockDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ErrorDto {
  final String text;
  final String code;
  final dynamic params;

  ErrorDto({required this.text, required this.code, required this.params});

  static ErrorDto fromJson(JsonObject value) => _$ErrorDtoFromJson(value);

  JsonObject toJson() => _$ErrorDtoToJson(this);
}
