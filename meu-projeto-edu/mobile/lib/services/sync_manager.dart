import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class SyncManager {
  final CourseRepository repository;
  final Connectivity _connectivity;
  late final StreamSubscription<ConnectivityResult> _subscription;

  SyncManager({required this.repository, Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    if (result != ConnectivityResult.none) {
      await _syncPending();
    }
  }

  Future<void> _onConnectivityChanged(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      await _syncPending();
    }
  }

  Future<void> _syncPending() async {
    final pendingCourses = await repository.getPendingSyncCourses();
    for (final course in pendingCourses) {
      try {
        await repository.syncCourse(course);
      } catch (_) {
        // Keep the pending record for later retry.
      }
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
