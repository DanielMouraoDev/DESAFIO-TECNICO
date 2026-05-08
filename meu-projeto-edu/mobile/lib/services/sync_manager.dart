import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../repositories/course_repository.dart';

class SyncManager {
  final CourseRepository repository;
  final Connectivity _connectivity;
  late final StreamSubscription<ConnectivityResult> _subscription;
  late final Timer _timer;
  bool _isSyncing = false;
  
  final _syncController = StreamController<void>.broadcast();
  Stream<void> get onSyncComplete => _syncController.stream;

  SyncManager({required this.repository, Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    // Periodically try to sync in case the server was down but connectivity didn't change
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => initialize());
  }

  Future<void> initialize() async {
    if (_isSyncing) return;
    _isSyncing = true;
    
    try {
      final result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        await repository.syncPendingCourses();
        await repository.syncRemoteCourses();
      }
    } catch (_) {
      // Keep local content available even if remote synchronization fails.
    } finally {
      _isSyncing = false;
      _syncController.add(null);
    }
  }

  Future<void> _onConnectivityChanged(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      await initialize();
    }
  }

  void dispose() {
    _subscription.cancel();
    _timer.cancel();
    _syncController.close();
  }
}
