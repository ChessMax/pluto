// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonDto _$LessonDtoFromJson(Map<String, dynamic> json) => LessonDto(
  id: (json['id'] as num).toInt(),
  steps:
      (json['steps'] as List<dynamic>?)
          ?.map((e) => StepDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  actions: ActionsDto.fromJson(json['actions'] as Map<String, dynamic>),
  progress: json['progress'] as String,
  subscriptions:
      (json['subscriptions'] as List<dynamic>).map((e) => e as String).toList(),
  viewedBy: (json['viewed_by'] as num).toInt(),
  passedBy: (json['passed_by'] as num).toInt(),
  timeToComplete: json['time_to_complete'],
  coverUrl: json['cover_url'] as String?,
  isCommentsEnabled: json['is_comments_enabled'] as bool,
  isExamWithoutProgress: json['is_exam_without_progress'] as bool,
  isBlank: json['is_blank'] as bool,
  isDraft: json['is_draft'] as bool,
  isOrphaned: json['is_orphaned'] as bool,
  courses:
      (json['courses'] as List<dynamic>?)
          ?.map((e) => CourseDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  units:
      (json['units'] as List<dynamic>?)
          ?.map((e) => UnitDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  owner: (json['owner'] as num).toInt(),
  language: json['language'] as String,
  isFeatured: json['is_featured'] as bool,
  isPublic: json['is_public'] as bool,
  canonicalUrl: json['canonical_url'] as String,
  title: json['title'] as String,
  slug: json['slug'] as String,
  createDate: json['create_date'] as String,
  updateDate: json['update_date'] as String,
  learnersGroup: (json['learners_group'] as num).toInt(),
  testersGroup: (json['testers_group'] as num).toInt(),
  moderatorsGroup: (json['moderators_group'] as num).toInt(),
  assistantsGroup: (json['assistants_group'] as num).toInt(),
  teachersGroup: (json['teachers_group'] as num).toInt(),
  adminsGroup: (json['admins_group'] as num).toInt(),
  discussionsCount: (json['discussions_count'] as num).toInt(),
  discussionProxy: json['discussion_proxy'] as String,
  discussionThreads:
      (json['discussion_threads'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  epicCount: (json['epic_count'] as num).toInt(),
  abuseCount: (json['abuse_count'] as num).toInt(),
  voteDelta: (json['vote_delta'] as num).toInt(),
  vote: json['vote'],
  ltiConsumerKey: json['lti_consumer_key'] as String,
  ltiSecretKey: json['lti_secret_key'] as String,
  ltiPrivateProfile: json['lti_private_profile'] as bool,
);

Map<String, dynamic> _$LessonDtoToJson(LessonDto instance) => <String, dynamic>{
  'id': instance.id,
  'steps': instance.steps,
  'actions': instance.actions,
  'progress': instance.progress,
  'subscriptions': instance.subscriptions,
  'viewed_by': instance.viewedBy,
  'passed_by': instance.passedBy,
  'time_to_complete': instance.timeToComplete,
  'cover_url': instance.coverUrl,
  'is_comments_enabled': instance.isCommentsEnabled,
  'is_exam_without_progress': instance.isExamWithoutProgress,
  'is_blank': instance.isBlank,
  'is_draft': instance.isDraft,
  'is_orphaned': instance.isOrphaned,
  'courses': instance.courses,
  'units': instance.units,
  'owner': instance.owner,
  'language': instance.language,
  'is_featured': instance.isFeatured,
  'is_public': instance.isPublic,
  'canonical_url': instance.canonicalUrl,
  'title': instance.title,
  'slug': instance.slug,
  'create_date': instance.createDate,
  'update_date': instance.updateDate,
  'learners_group': instance.learnersGroup,
  'testers_group': instance.testersGroup,
  'moderators_group': instance.moderatorsGroup,
  'assistants_group': instance.assistantsGroup,
  'teachers_group': instance.teachersGroup,
  'admins_group': instance.adminsGroup,
  'discussions_count': instance.discussionsCount,
  'discussion_proxy': instance.discussionProxy,
  'discussion_threads': instance.discussionThreads,
  'epic_count': instance.epicCount,
  'abuse_count': instance.abuseCount,
  'vote_delta': instance.voteDelta,
  'vote': instance.vote,
  'lti_consumer_key': instance.ltiConsumerKey,
  'lti_secret_key': instance.ltiSecretKey,
  'lti_private_profile': instance.ltiPrivateProfile,
};

ActionsDto _$ActionsDtoFromJson(Map<String, dynamic> json) => ActionsDto(
  learnLesson: json['learn_lesson'] as String,
  assistLesson: json['assist_lesson'] as String,
  viewAllSubmissions: json['view_all_submissions'] as String,
  editLesson: json['edit_lesson'] as String,
  viewStatistics: json['view_statistics'] as String,
  attachments: json['attachments'] as String,
  cloneLesson: json['clone_lesson'] as String,
  adminLesson: json['admin_lesson'] as String,
  editPermissions: json['edit_permissions'] as String,
  deleteLesson: json['delete_lesson'] as String,
);

Map<String, dynamic> _$ActionsDtoToJson(ActionsDto instance) =>
    <String, dynamic>{
      'learn_lesson': instance.learnLesson,
      'assist_lesson': instance.assistLesson,
      'view_all_submissions': instance.viewAllSubmissions,
      'edit_lesson': instance.editLesson,
      'view_statistics': instance.viewStatistics,
      'attachments': instance.attachments,
      'clone_lesson': instance.cloneLesson,
      'admin_lesson': instance.adminLesson,
      'edit_permissions': instance.editPermissions,
      'delete_lesson': instance.deleteLesson,
    };
