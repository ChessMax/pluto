import 'package:pluto/domain/course.dart';
import 'package:test/test.dart';

void main() {
  Course course() => Course(id: 42, title: 'Course');

  group('toDto publication flags', () {
    test('preserves a published remote course', () {
      final dto = course().toDto({
        'id': 42,
        'is_public': true,
        'is_enabled': true,
      });

      expect(dto['is_public'], isTrue);
      expect(dto['is_enabled'], isTrue);
    });

    test('preserves an unpublished remote course', () {
      final dto = course().toDto({
        'id': 42,
        'is_public': false,
        'is_enabled': false,
      });

      expect(dto['is_public'], isFalse);
      expect(dto['is_enabled'], isFalse);
    });

    test('creates a new course unpublished', () {
      final dto = Course(id: null, title: 'New').toDto();

      // Present, not merely false: Stepik reads an absent flag as published.
      expect(dto.containsKey('is_public'), isTrue);
      expect(dto.containsKey('is_enabled'), isTrue);
      expect(dto['is_public'], isFalse);
      expect(dto['is_enabled'], isFalse);
    });

    test('falls back to unpublished when the base omits the flags', () {
      final dto = course().toDto({'id': 42, 'title': 'Remote'});

      expect(dto['is_public'], isFalse);
      expect(dto['is_enabled'], isFalse);
    });

    test('never lets a local isPublic reach the payload', () {
      final dto = Course(
        id: 42,
        title: 'Course',
        isPublic: true,
      ).toDto({'id': 42, 'is_public': false, 'is_enabled': false});

      expect(dto['is_public'], isFalse);
      expect(dto['is_enabled'], isFalse);
    });
  });

  test('copyWith carries isPublic', () {
    expect(course().copyWith(isPublic: true).isPublic, isTrue);
    expect(
      course().copyWith(isPublic: true).copyWith(title: 'x').isPublic,
      isTrue,
    );
  });
}
