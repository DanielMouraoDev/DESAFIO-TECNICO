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
    await apiClient.createCourse(course.toApiJson());
    if (course.id != null) {
      await localDatabase.markCourseSynced(course.id!);
    }
  }
}
