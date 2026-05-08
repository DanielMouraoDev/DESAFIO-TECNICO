import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

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
      try {
        await repository.syncPendingCourses();
        await repository.syncRemoteCourses();
      } catch (_) {
        // Keep local content available even if remote synchronization fails.
      }
    }
  }

  Future<void> _onConnectivityChanged(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      try {
        await repository.syncPendingCourses();
        await repository.syncRemoteCourses();
      } catch (_) {
        // Keep local content available even if remote synchronization fails.
      }
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
