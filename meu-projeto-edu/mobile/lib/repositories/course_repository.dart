import '../models/course.dart';
import '../services/api_client.dart';
import '../services/local_database.dart';

class CourseRepository {
  final LocalDatabase localDatabase;
  final ApiClient apiClient;

  CourseRepository({LocalDatabase? localDatabase, ApiClient? apiClient})
      : localDatabase = localDatabase ?? LocalDatabase.instance,
        apiClient = apiClient ?? ApiClient();

  Future<List<Course>> loadCourses() async {
    return localDatabase.getCourses();
  }

  Future<Course> createCourse(Course course, {bool offline = true}) async {
    final storedCourse = await localDatabase.saveCourse(
      course.copyWith(pendingSync: offline),
    );
    if (!offline) {
      await syncCourse(storedCourse);
    }
    return storedCourse;
  }

  Future<List<Course>> getPendingSyncCourses() async {
    return localDatabase.getPendingSyncCourses();
  }

  Future<void> syncCourse(Course course) async {
    final response = await apiClient.createCourse(course.toApiJson());
    if (course.id != null) {
      final remoteId = response['id'] as int?;
      await localDatabase.markCourseSynced(course.id!, remoteId: remoteId);
    }
  }

  Future<void> syncRemoteCourses() async {
    final remoteCourses = await apiClient.fetchCourses();
    final courses = remoteCourses
        .map((json) => Course.fromApi(json))
        .toList();
    await localDatabase.saveCourses(courses);
  }

  Future<void> syncPendingCourses() async {
    final pendingCourses = await getPendingSyncCourses();
    for (final course in pendingCourses) {
      try {
        await syncCourse(course);
      } catch (_) {
        // Keep the pending course until the next retry.
      }
    }
  }
}
