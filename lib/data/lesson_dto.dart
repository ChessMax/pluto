import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/create_course_response.dart';
import 'package:pluto/data/create_step_response.dart';
import 'package:pluto/data/create_unit_response.dart';
import 'package:pluto/data/json.dart';
import 'package:pluto/data/step_dto.dart';

part 'lesson_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LessonDto {
  final int id;
  final List<int> steps;
  // final List<StepDto> steps;
  final ActionsDto actions;

  // "actions": {
  // "76-2217819",
  final String? progress;

  // [
  //   "31-76-2217819",
  //   "30-76-2217819"
  // ],
  final List<String> subscriptions;
  final int viewedBy;
  final int passedBy;
  final dynamic? timeToComplete;
  final String? coverUrl;
  final bool isCommentsEnabled;
  final bool isExamWithoutProgress;
  final bool isBlank;
  final bool isDraft;
  final bool isOrphaned;
  // final List<CourseDto> courses;
  final List<int> courses;
  // final List<UnitDto> units;
  final List<int> units;
  final int owner;
  final String language;
  final bool isFeatured;
  final bool isPublic;
  final String canonicalUrl;
  final String title;
  final String slug;

  // "2026-02-05T13:42:10.378Z"
  final String createDate;
  final String updateDate;
  // final int learnersGroup;
  // final int testersGroup;
  // final int moderatorsGroup;
  // final int assistantsGroup;
  // final int teachersGroup;
  // final int adminsGroup;
  // final int discussionsCount;

  // "76-2217819-1",
  // final String discussionProxy;

  // [
  //  "76-2217819-1"
  // ]
  // final List<String> discussionThreads;
  // final int epicCount;
  // final int abuseCount;
  // final int voteDelta;
  // final dynamic? vote;
  // final String ltiConsumerKey;
  // final String ltiSecretKey;
  // final bool ltiPrivateProfile;

  LessonDto({
    required this.id,
    this.steps = const [],
    required this.actions,
    required this.progress,
    required this.subscriptions,
    required this.viewedBy,
    required this.passedBy,
    required this.timeToComplete,
    this.coverUrl,
    required this.isCommentsEnabled,
    required this.isExamWithoutProgress,
    required this.isBlank,
    required this.isDraft,
    required this.isOrphaned,
    this.courses = const [],
    this.units = const [],
    required this.owner,
    required this.language,
    required this.isFeatured,
    required this.isPublic,
    required this.canonicalUrl,
    required this.title,
    required this.slug,
    required this.createDate,
    required this.updateDate,
    // required this.learnersGroup,
    // required this.testersGroup,
    // required this.moderatorsGroup,
    // required this.assistantsGroup,
    // required this.teachersGroup,
    // required this.adminsGroup,
    // required this.discussionsCount,
    // required this.discussionProxy,
    // required this.discussionThreads,
    // required this.epicCount,
    // required this.abuseCount,
    // required this.voteDelta,
    // this.vote,
    // required this.ltiConsumerKey,
    // required this.ltiSecretKey,
    // required this.ltiPrivateProfile,
  });

  static LessonDto fromJson(JsonObject value) => _$LessonDtoFromJson(value);

  JsonObject toJson() => _$LessonDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ActionsDto {
  // #
  final String? learnLesson;

  // #
  final String? assistLesson;

  // #
  final String? viewAllSubmissions;

  // #
  final String? editLesson;

  // #
  final String? viewStatistics;

  // "/lesson/2217819/attachments/"
  final String? attachments;

  // "/lesson/2217819/clone/"
  final String? cloneLesson;

  // #
  final String? adminLesson;

  // "/lesson/2217819/permissions/"
  final String? editPermissions;

  // #
  final String? deleteLesson;

  const ActionsDto({
    required this.learnLesson,
    required this.assistLesson,
    required this.viewAllSubmissions,
    required this.editLesson,
    required this.viewStatistics,
    required this.attachments,
    required this.cloneLesson,
    required this.adminLesson,
    required this.editPermissions,
    required this.deleteLesson,
  });

  static ActionsDto fromJson(JsonObject value) => _$ActionsDtoFromJson(value);

  JsonObject toJson() => _$ActionsDtoToJson(this);
}
