import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/create_section_response.dart';
import 'package:pluto/data/json.dart';
import 'package:pluto/data/meta_dto.dart';
import 'package:pluto/data/stepik_list_response.dart';

part 'create_course_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateCourseResponse extends StepikListResponse {
  final List<CourseDto> courses;
  final List<EnrollmentDto> enrollments;

  CreateCourseResponse({
    required super.meta,
    required this.courses,
    required this.enrollments,
  });

  static CreateCourseResponse fromJson(JsonObject value) =>
      _$CreateCourseResponseFromJson(value);

  JsonObject toJson() => _$CreateCourseResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CourseDto {
  final int id;
  final String summary;
  final String workload;
  final String? cover;
  final String intro;
  final String courseFormat;
  final String targetAudience;
  final dynamic? certificateFooter;
  final dynamic? certificateCoverOrg;
  final bool isCertificateIssued;
  final bool isCertificateAutoIssued;
  final int certificateRegularThreshold;
  final int certificateDistinctionThreshold;
  final List<int> instructors;
  final String certificate;
  final String requirements;
  final String description;
  final List<SectionDto> sections;
  final int totalUnits;
  final int enrollment;
  final bool isFavorite;

  // "actions": {
  //   "view_reports": {
  //     "enabled": true
  //   },
  //   "edit_reports": {
  //     "enabled": false,
  //     "needs_plan": "enterprise"
  //   },
  //   "view_grade_book_page": {
  //     "enabled": true
  //   },
  //   "view_grade_book": {
  //     "enabled": false,
  //     "needs_plan": "enterprise"
  //   },
  //   "edit_lti": {
  //     "enabled": false,
  //     "needs_plan": "enterprise"
  //   },
  //   "edit_advanced_settings": {
  //     "enabled": false,
  //     "needs_plan": "enterprise"
  //   },
  //   "manage_permissions": {
  //     "enabled": false,
  //     "needs_plan": "enterprise"
  //   },
  //   "assist_course": "#",
  //   "view_instructor_dashboard": "#",
  //   "edit_course": "/course/274156/edit-info",
  //   "edit_syllabus": "/course/274156/edit",
  //   "view_statistics": "/course/274156/statistics/",
  //   "attachments": "/course/274156/attachments/",
  //   "create_announcements": "#",
  //   "clone_course": "/course/274156/clone/",
  //   "clone_module": "/course/274156/clone-module/",
  //   "can_publish": {
  //     "enabled": true,
  //     "needs_plan": null
  //   },
  //   "can_be_private": {
  //     "enabled": false,
  //     "needs_plan": "enterprise"
  //   },
  //   "admin_course": "#",
  //   "edit_permissions": "/course/274156/edit-permissions",
  //   "edit_publish_settings": "#",
  //   "transfer_ownership": "/course/274156/transfer/",
  //   "view_revenue": {
  //     "enabled": false
  //   },
  //   "can_be_bought": {
  //     "enabled": false
  //   },
  //   "can_be_price_changed": {
  //     "enabled": true
  //   },
  //   "can_be_deleted": {
  //     "enabled": true
  //   },
  //   "edit_tags": {
  //     "enabled": true
  //   }
  // },
  // "78-274156"
  final String progress;
  final dynamic? firstLesson;
  final dynamic? firstUnit;
  final String? certificateLink;
  final String certificateRegularLink;
  final String certificateDistinctionLink;
  final String? userCertificate;
  final String referralLink;
  final String scheduleLink;
  final String scheduleLongLink;
  final dynamic? firstDeadline;
  final dynamic? lastDeadline;
  final List<String> subscriptions;
  final List<dynamic> announcements;
  final bool isContest;
  final bool isSelfPaced;
  final bool isAdaptive;
  final bool isIdeaCompatible;
  final bool isInWishlist;
  final String lastStep;
  final String? introVideo;
  final List<dynamic> socialProviders;
  final List<int> authors;
  final List<String> tags;
  final bool hasTutors;
  final bool isEnabled;
  final bool isProctored;
  final String? proctorUrl;
  final int reviewSummary;

  // "self_paced"
  final String scheduleType;
  final int certificatesCount;
  final int learnersCount;
  final int lessonsCount;
  final int quizzesCount;
  final int challengesCount;
  final int peerReviewsCount;
  final int instructorReviewsCount;
  final int videosDuration;
  final int? timeToComplete;
  final bool isPopular;
  final bool isProcessedWithPaddle;
  final bool isUnsuitable;
  final bool isPaid;
  final dynamic? price;
  final String? currencyCode;
  final String displayPrice;
  final dynamic? defaultPromoCodeName;
  final dynamic? defaultPromoCodePrice;
  final dynamic? defaultPromoCodeDiscount;
  final dynamic? defaultPromoCodeIsPercentDiscount;
  final dynamic? defaultPromoCodeExpireDate;

  // "/course/274156/continue"
  final String continueUrl;
  final int readiness;

  final bool isArchived;
  final dynamic options;
  final dynamic? priceTier;
  final int position;
  final bool isCensored;
  final dynamic difficulty;
  final List<dynamic> acquiredSkills;
  final List<dynamic> acquiredAssets;
  final String learningFormat;
  final List<dynamic> contentDetails;
  final int issue;

  // "basic"
  final String courseType;

  // "basic"
  final String possibleType;
  final bool isCertificateWithScore;
  final dynamic? previewLesson;
  final dynamic? previewUnit;
  final List<String> possibleCurrencies;
  // final String? commissionBasic;
  // final String commissionPromo;
  // final bool withCertificate;
  final List<CourseDto> childCourses;
  final int childCoursesCount;
  final List<CourseDto> parentCourses;

  // "2026-02-05T18:42:06.803Z"
  final String? becamePublishedAt;
  final String? becamePaidAt;
  final String titleEn;
  final String? lastUpdatePriceDate;
  final int owner;
  final String language;
  final bool isFeatured;
  final bool isPublic;

  // "https://stepik.org/course/274156/"
  final String canonicalUrl;
  final String title;

  // "My-Course-274156"
  final String slug;
  final String? beginDate;
  final String? endDate;
  final String? softDeadline;
  final String? hardDeadline;

  // "halved"
  final String gradingPolicy;
  final String? beginDateSource;
  final String? endDateSource;
  final String? softDeadlineSource;
  final String? hardDeadlineSource;

  // "halved"
  final String gradingPolicySource;
  final bool isActive;

  // "2026-02-05T18:42:06.804Z"
  final String createDate;
  final String updateDate;
  final int learnersGroup;
  final int testersGroup;
  final int moderatorsGroup;
  final int assistantsGroup;
  final int teachersGroup;
  final int adminsGroup;
  final int discussionsCount;

  // "78-274156-1"
  final String discussionProxy;

  // [
  // "78-274156-1"
  // ]
  final List<String> discussionThreads;
  final String ltiConsumerKey;
  final String ltiSecretKey;
  final bool ltiPrivateProfile;

  CourseDto({
    required this.id,
    required this.summary,
    required this.workload,
    this.cover,
    required this.intro,
    required this.courseFormat,
    required this.targetAudience,
    this.certificateFooter,
    this.certificateCoverOrg,
    required this.isCertificateIssued,
    required this.isCertificateAutoIssued,
    required this.certificateRegularThreshold,
    required this.certificateDistinctionThreshold,
    required this.instructors,
    required this.certificate,
    required this.requirements,
    required this.description,
    required this.sections,
    required this.totalUnits,
    required this.enrollment,
    required this.isFavorite,
    required this.progress,
    this.firstLesson,
    this.firstUnit,
    this.certificateLink,
    required this.certificateRegularLink,
    required this.certificateDistinctionLink,
    this.userCertificate,
    required this.referralLink,
    required this.scheduleLink,
    required this.scheduleLongLink,
    this.firstDeadline,
    this.lastDeadline,
    required this.subscriptions,
    required this.announcements,
    required this.isContest,
    required this.isSelfPaced,
    required this.isAdaptive,
    required this.isIdeaCompatible,
    required this.isInWishlist,
    required this.lastStep,
    this.introVideo,
    required this.socialProviders,
    required this.authors,
    required this.tags,
    required this.hasTutors,
    required this.isEnabled,
    required this.isProctored,
    this.proctorUrl,
    required this.reviewSummary,
    required this.scheduleType,
    required this.certificatesCount,
    required this.learnersCount,
    required this.lessonsCount,
    required this.quizzesCount,
    required this.challengesCount,
    required this.peerReviewsCount,
    required this.instructorReviewsCount,
    required this.videosDuration,
    this.timeToComplete,
    required this.isPopular,
    required this.isProcessedWithPaddle,
    required this.isUnsuitable,
    required this.isPaid,
    this.price,
    this.currencyCode,
    required this.displayPrice,
    this.defaultPromoCodeName,
    this.defaultPromoCodePrice,
    this.defaultPromoCodeDiscount,
    this.defaultPromoCodeIsPercentDiscount,
    this.defaultPromoCodeExpireDate,
    required this.continueUrl,
    required this.readiness,
    required this.isArchived,
    this.options,
    this.priceTier,
    required this.position,
    required this.isCensored,
    this.difficulty,
    required this.acquiredSkills,
    required this.acquiredAssets,
    required this.learningFormat,
    required this.contentDetails,
    required this.issue,
    required this.courseType,
    required this.possibleType,
    required this.isCertificateWithScore,
    this.previewLesson,
    this.previewUnit,
    required this.possibleCurrencies,
    // required this.commissionBasic,
    // required this.commissionPromo,
    // required this.withCertificate,
    required this.childCourses,
    required this.childCoursesCount,
    required this.parentCourses,
    required this.becamePublishedAt,
    this.becamePaidAt,
    required this.titleEn,
    this.lastUpdatePriceDate,
    required this.owner,
    required this.language,
    required this.isFeatured,
    required this.isPublic,
    required this.canonicalUrl,
    required this.title,
    required this.slug,
    this.beginDate,
    this.endDate,
    this.softDeadline,
    this.hardDeadline,
    required this.gradingPolicy,
    this.beginDateSource,
    this.endDateSource,
    this.softDeadlineSource,
    this.hardDeadlineSource,
    required this.gradingPolicySource,
    required this.isActive,
    required this.createDate,
    required this.updateDate,
    required this.learnersGroup,
    required this.testersGroup,
    required this.moderatorsGroup,
    required this.assistantsGroup,
    required this.teachersGroup,
    required this.adminsGroup,
    required this.discussionsCount,
    required this.discussionProxy,
    required this.discussionThreads,
    required this.ltiConsumerKey,
    required this.ltiSecretKey,
    required this.ltiPrivateProfile,
  });

  static CourseDto fromJson(JsonObject value) =>
      _$CourseDtoFromJson(value);

  JsonObject toJson() => _$CourseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EnrollmentDto {
  final int id;
  final int course;

  EnrollmentDto({
    required this.id,
    required this.course
  });

  static EnrollmentDto fromJson(JsonObject value) =>
      _$EnrollmentDtoFromJson(value);

  JsonObject toJson() => _$EnrollmentDtoToJson(this);
}
