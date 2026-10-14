import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:muit_sales_app/models/log_model.dart';

class LogService extends GetxService with WidgetsBindingObserver {
  static LogService get to => Get.find<LogService>();
  final GetStorage _storage = GetStorage();

  DateTime? _appStartTime;
  final RxInt currentSessionSeconds = 0.obs;
  Timer? _timer;

  final RxList<LogModel> rxLogs = <LogModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadLogs();
    _startUsageSession();
  }

  @override
  void onClose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // ---------- APP LIFECYCLE FOR USAGE TIME TRACKING ----------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startUsageSession();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _endUsageSession();
    }
  }

  void _startUsageSession() {
    _appStartTime = DateTime.now();
    currentSessionSeconds.value = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_appStartTime != null) {
        currentSessionSeconds.value =
            DateTime.now().difference(_appStartTime!).inSeconds;
      }
    });
  }

  void _endUsageSession() {
    _timer?.cancel();
    if (_appStartTime != null) {
      final seconds = DateTime.now().difference(_appStartTime!).inSeconds;
      if (seconds > 3) {
        addLog(
          actionType: 'APP_USAGE',
          description: 'App used for ${_formatDuration(seconds)}',
          extraData: {'duration_seconds': seconds},
        );
      }
    }
  }

  String _formatDuration(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    if (mins == 0) {
      return '$secs secs';
    }
    return '$mins mins $secs secs';
  }

  // ---------- ADD LOG METHOD ----------

  Future<void> addLog({
    required String actionType,
    required String description,
    Map<String, dynamic>? extraData,
  }) async {
    final userId = _storage.read('user_id') ?? '101';
    final userName = _storage.read('user_name') ?? 'Counsellor';

    final now = DateTime.now();
    final timeStr =
        '${now.year}-${_two(now.month)}-${_two(now.day)} ${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}';

    final log = LogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId.toString(),
      userName: userName.toString(),
      actionType: actionType,
      description: description,
      timestamp: timeStr,
      extraData: extraData,
    );

    List stored = _storage.read('app_activity_logs') ?? [];
    stored.insert(0, log.toJson());
    await _storage.write('app_activity_logs', stored);

    loadLogs(); // Update reactive list
    debugPrint('📌 [LOG RECORDED] ${log.actionType}: ${log.description}');
  }

  void loadLogs() {
    List stored = _storage.read('app_activity_logs') ?? [];
    rxLogs.value = stored
        .map((e) => LogModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List<LogModel> getLogs() => rxLogs;

  String _two(int n) => n.toString().padLeft(2, '0');
}
