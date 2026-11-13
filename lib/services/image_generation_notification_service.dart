import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Progress notifications for on-device image generation.
///
/// Generation runs in the app's own isolate while it is on screen; these
/// notifications simply mirror its progress. No foreground service is used,
/// so backgrounded generation is not kept alive by the OS.
class ImageGenerationNotificationService {
  static const int _progressNotificationId = 4201;
  static const String _channelId = 'image_generation_progress';
  static const String _channelName = 'Image generation';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Progress updates for local image generation',
            importance: Importance.low,
          ),
        );
    _initialized = true;
  }

  Future<void> ensurePermission() async {
    if (!Platform.isAndroid) return;
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await Permission.notification.request();
  }

  Future<void> start({
    required String modelName,
    required String backend,
    required int steps,
    required String sizeLabel,
  }) async {
    if (!Platform.isAndroid) return;
    await init();
    await ensurePermission();
    await _showProgress(
      title: 'Image generation running',
      body: '0% · Step 0 of $steps',
      progress: 0,
      maxProgress: steps <= 0 ? 100 : steps,
      indeterminate: steps <= 0,
    );
  }

  Future<void> update({
    required int step,
    required int total,
    required int etaSeconds,
    required int elapsedSeconds,
  }) async {
    if (!Platform.isAndroid) return;
    final percent = total > 0 ? ((step / total) * 100).clamp(0, 100).round() : 0;
    final eta = etaSeconds > 0 ? ' · ~${_formatEta(etaSeconds)} left' : '';
    final elapsed = ' · ${_formatEta(elapsedSeconds)} elapsed';
    final body = total > 0
        ? '$percent% · Step $step of $total$elapsed$eta'
        : 'Working$elapsed';
    await _showProgress(
      title: 'Image generation running',
      body: body,
      progress: total > 0 ? step.clamp(0, total).toInt() : 0,
      maxProgress: total <= 0 ? 100 : total,
      indeterminate: total <= 0,
    );
  }

  Future<void> decoding() async {
    if (!Platform.isAndroid) return;
    await _showProgress(
      title: 'Finishing image',
      body: 'Decoding image...',
      progress: 100,
      maxProgress: 100,
      indeterminate: true,
    );
  }

  Future<void> complete({required int durationMs}) async {
    if (!Platform.isAndroid) return;
    await _notifications.show(
      _progressNotificationId,
      'Image ready',
      'Generation finished in ${_formatDuration(durationMs)}.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Progress updates for local image generation',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          onlyAlertOnce: true,
        ),
      ),
    );
    await _notifications.cancel(_progressNotificationId);
  }

  Future<void> failed() async {
    if (!Platform.isAndroid) return;
    await _notifications.show(
      _progressNotificationId,
      'Image generation failed',
      'Open PhoneLM to check the error and try again.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Progress updates for local image generation',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          onlyAlertOnce: true,
        ),
      ),
    );
  }

  Future<void> cancel() async {
    if (!Platform.isAndroid) return;
    await _notifications.cancel(_progressNotificationId);
  }

  Future<void> _showProgress({
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
    required bool indeterminate,
  }) async {
    await _notifications.show(
      _progressNotificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Progress updates for local image generation',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: maxProgress,
          progress: progress,
          indeterminate: indeterminate,
        ),
      ),
    );
  }

  String _formatEta(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return rest == 0 ? '${minutes}m' : '${minutes}m ${rest}s';
  }

  String _formatDuration(int ms) {
    final seconds = (ms / 1000).round();
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return rest == 0 ? '${minutes}m' : '${minutes}m ${rest}s';
  }
}
