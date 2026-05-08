import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../services/sync_manager.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository();
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  final repository = ref.watch(courseRepositoryProvider);
  final manager = SyncManager(repository: repository);
  ref.onDispose(manager.dispose);
  return manager;
});

final courseListProvider = StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
  final repository = ref.watch(courseRepositoryProvider);
  final syncManager = ref.watch(syncManagerProvider);
  return CourseNotifier(repository, syncManager);
});

class CourseNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  final CourseRepository repository;
  final SyncManager syncManager;
  StreamSubscription? _syncSubscription;

  CourseNotifier(this.repository, this.syncManager) : super(const AsyncValue.loading()) {
    _loadCourses();
    // Listen for sync completions to update the UI automatically
    _syncSubscription = syncManager.onSyncComplete.listen((_) => _reloadLocalData());
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      await syncManager.initialize();
      await _reloadLocalData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _reloadLocalData() async {
    final courses = await repository.loadCourses();
    state = AsyncValue.data(courses);
  }

  Future<void> addCourse(String title, String description) async {
    // 1. Optimistic update or just show loading
    try {
      // Save locally (offline-first)
      await repository.createCourse(
        Course(title: title, description: description, pendingSync: true),
      );
      
      // Update UI with local data
      await _reloadLocalData();

      // Trigger sync in background
      syncManager.initialize();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      await syncManager.initialize();
      await _reloadLocalData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
