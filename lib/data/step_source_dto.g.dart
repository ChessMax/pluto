// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_source_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepSourceDto _$StepSourceDtoFromJson(Map<String, dynamic> json) =>
    StepSourceDto(
      id: (json['id'] as num).toInt(),
      lesson: (json['lesson'] as num).toInt(),
      position: (json['position'] as num).toInt(),
      status: json['status'] as String,
      block: BlockDto.fromJson(json['block'] as Map<String, dynamic>),
      progress: json['progress'] as String,
      subscriptions: (json['subscriptions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      instruction: json['instruction'],
      session: json['session'],
      instructionType: json['instruction_type'],
      viewedBy: (json['viewed_by'] as num?)?.toInt() ?? 0,
      passedBy: (json['passed_by'] as num?)?.toInt() ?? 0,
      correctRatio: json['correct_ratio'],
      worth: (json['worth'] as num?)?.toInt() ?? 0,
      isSolutionsUnlocked: json['is_solutions_unlocked'] as bool,
      solutionsUnlockedAttempts: (json['solutions_unlocked_attempts'] as num)
          .toInt(),
      hasSubmissionsRestrictions: json['has_submissions_restrictions'] as bool,
      maxSubmissionsCount: (json['max_submissions_count'] as num).toInt(),
      variation: (json['variation'] as num).toInt(),
      variationsCount: (json['variations_count'] as num).toInt(),
      isEnabled: json['is_enabled'] as bool,
      needsPlan: json['needs_plan'],
      numGrades: (json['num_grades'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      userStepGrade: json['user_step_grade'],
      userStepVote: json['user_step_vote'],
      createDate: json['create_date'] as String,
      updateDate: json['update_date'] as String,
      discussionsCount: (json['discussions_count'] as num).toInt(),
      discussionProxy: json['discussion_proxy'] as String,
      discussionThreads: (json['discussion_threads'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reasonOfFailure: json['reason_of_failure'] as String,
      error: ErrorDto.fromJson(json['error'] as Map<String, dynamic>),
      warnings: json['warnings'] as List<dynamic>,
      cost: (json['cost'] as num).toInt(),
    );

Map<String, dynamic> _$StepSourceDtoToJson(StepSourceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lesson': instance.lesson,
      'position': instance.position,
      'status': instance.status,
      'block': instance.block,
      'progress': instance.progress,
      'subscriptions': instance.subscriptions,
      'instruction': instance.instruction,
      'session': instance.session,
      'instruction_type': instance.instructionType,
      'viewed_by': instance.viewedBy,
      'passed_by': instance.passedBy,
      'correct_ratio': instance.correctRatio,
      'worth': instance.worth,
      'is_solutions_unlocked': instance.isSolutionsUnlocked,
      'solutions_unlocked_attempts': instance.solutionsUnlockedAttempts,
      'has_submissions_restrictions': instance.hasSubmissionsRestrictions,
      'max_submissions_count': instance.maxSubmissionsCount,
      'variation': instance.variation,
      'variations_count': instance.variationsCount,
      'is_enabled': instance.isEnabled,
      'needs_plan': instance.needsPlan,
      'num_grades': instance.numGrades,
      'user_step_grade': instance.userStepGrade,
      'user_step_vote': instance.userStepVote,
      'create_date': instance.createDate,
      'update_date': instance.updateDate,
      'discussions_count': instance.discussionsCount,
      'discussion_proxy': instance.discussionProxy,
      'discussion_threads': instance.discussionThreads,
      'reason_of_failure': instance.reasonOfFailure,
      'error': instance.error,
      'warnings': instance.warnings,
      'cost': instance.cost,
    };

BlockDto _$BlockDtoFromJson(Map<String, dynamic> json) => BlockDto(
  name: json['name'] as String,
  text: json['text'] as String,
  video: json['video'] as String?,
  options: json['options'],
  subtitleFiles: json['subtitle_files'] as List<dynamic>,
  isDeprecated: json['is_deprecated'] as bool,
  source: json['source'],
  subtitles: json['subtitles'],
  testsArchive: json['tests_archive'],
  feedbackCorrect: json['feedback_correct'] as String,
  feedbackWrong: json['feedback_wrong'] as String,
);

Map<String, dynamic> _$BlockDtoToJson(BlockDto instance) => <String, dynamic>{
  'name': instance.name,
  'text': instance.text,
  'video': instance.video,
  'options': instance.options,
  'subtitle_files': instance.subtitleFiles,
  'is_deprecated': instance.isDeprecated,
  'source': instance.source,
  'subtitles': instance.subtitles,
  'tests_archive': instance.testsArchive,
  'feedback_correct': instance.feedbackCorrect,
  'feedback_wrong': instance.feedbackWrong,
};

ErrorDto _$ErrorDtoFromJson(Map<String, dynamic> json) => ErrorDto(
  text: json['text'] as String,
  code: json['code'] as String,
  params: json['params'],
);

Map<String, dynamic> _$ErrorDtoToJson(ErrorDto instance) => <String, dynamic>{
  'text': instance.text,
  'code': instance.code,
  'params': instance.params,
};
