import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pluto/data/auth_response.dart';
import 'package:pluto/data/create_course_response.dart';
import 'package:pluto/data/create_lesson_response.dart';
import 'package:pluto/data/create_section_response.dart';
import 'package:pluto/data/create_step_response.dart';
import 'package:pluto/data/create_unit_response.dart';
import 'package:pluto/data/dio_extensions.dart';
import 'package:pluto/data/result.dart';

class StepikClient {
  final Dio _dio;

  StepikClient(this._dio);

  Result<AuthResponse> getToken(String clientId, String clientSecret) {
    final data = base64Encode(utf8.encode('$clientId:$clientSecret'));
    return _dio.postRequest(
      '/oauth2/token/',
      AuthResponse.fromJson,
      data: {'grant_type': 'client_credentials'},
      headers: {"Authorization": "Basic $data"},
      contentType: Headers.formUrlEncodedContentType,
    );
  }

  Result<CreateLessonResponse> createLesson(Map<String, dynamic> data) {
    return _dio.postRequest(
      data: data,
      '/api/lessons',
      CreateLessonResponse.fromJson,
    );
  }

  Result<StepResponse> createStep(Map<String, dynamic> data) {
    return _dio.postRequest(
      data: data,
      '/api/step-sources',
      StepResponse.fromJson,
    );
  }

  Result<StepResponse> updateStep(int stepId, Map<String, dynamic> data) {
    return _dio.putRequest(
      data: data,
      '/api/step-sources/$stepId',
      StepResponse.fromJson,
    );
  }

  Result<CreateCourseResponse> getCourse(String courseId) {
    return _dio.getRequest(
      '/api/courses/$courseId',
      CreateCourseResponse.fromJson,
    );
  }

  Result<CreateCourseResponse> createCourse(Map<String, dynamic> data) {
    return _dio.postRequest(
      data: data,
      '/api/courses',
      CreateCourseResponse.fromJson,
    );
  }

  // create module/section
  Result<CreateSectionResponse> createSection(Map<String, dynamic> data) {
    return _dio.postRequest(
      data: data,
      '/api/sections',
      CreateSectionResponse.fromJson,
    );
  }

  Result<CreateUnitResponse> createUnit(Map<String, dynamic> data) {
    return _dio.postRequest(
      data: data,
      '/api/units',
      CreateUnitResponse.fromJson,
    );
  }
}
