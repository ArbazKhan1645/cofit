// ============================================================
// local_notification_service.dart
// Sirf local notifications - schedules, reminders, background
// calculations se triggered hone wale notifications
// ============================================================

import 'dart:developer' as developer;
import 'package:cofit_collective/notifications/types.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class LocalNotificationService {
  LocalNotificationService._internal();
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification IDs - conflicts se bachne k liye fixed ranges
  static const int _workoutReminderBaseId = 1000;
  static const int _dailyGoalBaseId = 2000;
  static const int _streakWarningBaseId = 3000;
  static const int _hydrationBaseId = 4000;
  static const int _restDayBaseId = 5000;
  static const int _progressBaseId = 6000;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
    );

    await _createNotificationChannels();
    _initialized = true;
    developer.log(
      'LocalNotificationService initialized',
      name: 'Notifications',
    );
  }

  // ============================================================
  // ANDROID CHANNELS SETUP
  // ============================================================

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    final channels = [
      // High importance - user ne manually set kiye workout times
      const AndroidNotificationChannel(
        'workout_reminders',
        'Workout Reminders',
        description: 'Scheduled workout time reminders',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      const AndroidNotificationChannel(
        'streak_warnings',
        'Streak Warnings',
        description: 'Streak se related urgent alerts',
        importance: Importance.high,
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'achievement_alerts',
        'Achievement Alerts',
        description: 'Badges aur achievements',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        'daily_goal_reminders',
        'Daily Goal Reminders',
        description: 'Daily fitness goal reminders',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        'hydration_reminders',
        'Hydration Reminders',
        description: 'Paani peene ki yaad',
        importance: Importance.low,
      ),
      const AndroidNotificationChannel(
        'rest_day_reminders',
        'Rest Day Reminders',
        description: 'Recovery day suggestions',
        importance: Importance.low,
      ),
      const AndroidNotificationChannel(
        'progress_updates',
        'Progress Updates',
        description: 'Weekly aur monthly progress',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        'social_activity',
        'Social Activity',
        description: 'Likes, comments, follows',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        'challenge_updates',
        'Challenge Updates',
        description: 'Challenge progress aur updates',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        'community_challenges',
        'Community Challenges',
        description: 'New challenges aur invites',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        'subscription_alerts',
        'Subscription Alerts',
        description: 'Plan renewal aur billing',
        importance: Importance.high,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  // ============================================================
  // PERMISSION REQUEST
  // ============================================================

  Future<bool> requestPermissions() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  // ============================================================
  // IMMEDIATE LOCAL NOTIFICATION
  // ============================================================

  Future<void> showImmediate({
    required int id,
    required NotificationPayload payload,
  }) async {
    await _plugin.show(
      id: id,
      title: payload.title,
      body: payload.body,
      notificationDetails: _buildDetails(payload.channel),
      payload: _encodePayload(payload),
    );
  }

  // ============================================================
  // WORKOUT REMINDERS (Local Only - user schedule set karta hai)
  // ============================================================

  /// Workout reminder schedule karo specific time par
  Future<void> scheduleWorkoutReminder({
    required int dayOfWeek, // 1=Mon, 7=Sun
    required int hour,
    required int minute,
    required String workoutName,
    String? customMessage,
  }) async {
    final id = _workoutReminderBaseId + dayOfWeek;
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = _nextWeekdayTime(dayOfWeek, hour, minute);

    await _plugin.zonedSchedule(
      notificationDetails: _buildDetails(NotificationChannel.workoutReminder),
      id: id,
      scheduledDate: scheduledDate,

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: _encodePayload(
        NotificationPayload(
          title: '💪 Workout Time!',
          body: customMessage ?? 'Time for your $workoutName session',
          channel: NotificationChannel.workoutReminder,
          data: {'workout_name': workoutName, 'day_of_week': dayOfWeek},
          actionRoute: '/workout/start',
        ),
      ),
    );

    developer.log(
      'Workout reminder scheduled: Day $dayOfWeek at $hour:$minute',
      name: 'Notifications',
    );
  }

  /// Multiple workout reminders ek saath schedule karo
  Future<void> scheduleWeeklyWorkoutPlan({
    required Map<int, Map<String, dynamic>> weeklyPlan,
    // {1: {'time': '07:00', 'name': 'Chest Day'}, ...}
  }) async {
    await cancelAllWorkoutReminders();

    for (final entry in weeklyPlan.entries) {
      final dayOfWeek = entry.key;
      final planData = entry.value;
      final timeParts = (planData['time'] as String).split(':');

      await scheduleWorkoutReminder(
        dayOfWeek: dayOfWeek,
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
        workoutName: planData['name'] as String,
        customMessage: planData['message'] as String?,
      );
    }
  }

  Future<void> cancelAllWorkoutReminders() async {
    for (int i = 1; i <= 7; i++) {
      await _plugin.cancel(id: _workoutReminderBaseId + i);
    }
  }

  // ============================================================
  // STREAK WARNINGS (Background service trigger karta hai)
  // Jab user ne workout nahi kiya aur streak khatam hone wali ho
  // ============================================================

  Future<void> showStreakWarning({
    required int currentStreak,
    required int hoursLeft,
  }) async {
    String title;
    String body;

    if (hoursLeft <= 2) {
      title = '🚨 Streak Almost Gone!';
      body =
          'Sirf $hoursLeft ghante baaki hain! $currentStreak din ki streak bachao - abhi koi bhi workout karo!';
    } else if (hoursLeft <= 6) {
      title = '⚠️ Streak at Risk!';
      body =
          'Aaj workout nahi ki abhi tak. $currentStreak din ki streak $hoursLeft ghanton mein khatam ho jayegi.';
    } else {
      title = '🔥 Don\'t Break Your Streak!';
      body =
          'Aaj workout karna mat bhoolna. $currentStreak din ki streak hai - isko toda mat!';
    }

    await _plugin.show(
      id: _streakWarningBaseId,
      title: title,
      body: body,
      notificationDetails: _buildDetails(NotificationChannel.streakWarning),
      payload: _encodePayload(
        NotificationPayload(
          title: title,
          body: body,
          channel: NotificationChannel.streakWarning,
          data: {'current_streak': currentStreak, 'hours_left': hoursLeft},
          actionRoute: '/workout/quick-start',
        ),
      ),
    );
  }

  // ============================================================
  // DAILY GOAL REMINDERS (Background service track karta hai)
  // ============================================================

  Future<void> scheduleDailyGoalReminder({
    required int hour,
    required int minute,
  }) async {
    final scheduledDate = _nextDailyTime(hour, minute);

    await _plugin.zonedSchedule(
      id: _dailyGoalBaseId,
      title: '🎯 Daily Goal Check-In',
      body: 'Aaj ka goal kaise chal raha hai? Track karo aur top par raho!',
      scheduledDate: scheduledDate,
      notificationDetails: _buildDetails(NotificationChannel.dailyGoalReminder),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Background se call hota hai - actual progress ke saath
  Future<void> showGoalProgress({
    required int percentComplete,
    required String goalType,
    required int remaining,
    required String unit,
  }) async {
    String title;
    String body;

    if (percentComplete >= 100) {
      title = '✅ Goal Complete!';
      body = 'Zabardast! Aaj ka $goalType goal pura ho gaya!';
    } else if (percentComplete >= 75) {
      title = '💪 Almost There!';
      body = 'Sirf $remaining $unit aur baaki hai $goalType goal mein. Karo!';
    } else {
      title = '🎯 Goal Reminder';
      body =
          'Aaj ka $goalType: ${percentComplete}% complete. $remaining $unit baaki hai!';
    }

    await _plugin.show(
      id: _dailyGoalBaseId + 1,
      title: title,
      body: body,
      notificationDetails: _buildDetails(NotificationChannel.dailyGoalReminder),
      payload: _encodePayload(
        NotificationPayload(
          title: title,
          body: body,
          channel: NotificationChannel.dailyGoalReminder,
          data: {'percent': percentComplete, 'goal_type': goalType},
          actionRoute: '/goals/today',
        ),
      ),
    );
  }

  // ============================================================
  // HYDRATION REMINDERS (Local scheduled - health feature)
  // ============================================================

  Future<void> scheduleHydrationReminders({
    required int startHour, // e.g. 8
    required int endHour, // e.g. 22
    required int intervalMinutes, // e.g. 90
    int dailyGoalLiters = 2,
  }) async {
    await cancelHydrationReminders();

    int notifId = _hydrationBaseId;
    int hour = startHour;
    int minute = 0;

    while (hour < endHour) {
      final scheduledDate = _nextDailyTime(hour, minute);

      await _plugin.zonedSchedule(
        id: notifId++,
        title: '💧 Hydration Check',
        body:
            'Paani peene ka waqt! Daily goal: ${dailyGoalLiters}L. Chhota sa sip bhi count karta hai!',
        scheduledDate: scheduledDate,
        notificationDetails: _buildDetails(
          NotificationChannel.hydrationReminder,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Next interval calculate karo
      minute += intervalMinutes;
      hour += minute ~/ 60;
      minute = minute % 60;
    }

    developer.log(
      'Hydration reminders scheduled from $startHour:00 to $endHour:00 every $intervalMinutes mins',
      name: 'Notifications',
    );
  }

  Future<void> cancelHydrationReminders() async {
    for (int i = _hydrationBaseId; i < _hydrationBaseId + 20; i++) {
      await _plugin.cancel(id: i);
    }
  }

  // ============================================================
  // REST DAY REMINDER (Background service calculate karta hai)
  // Agar lagatar 5+ din workout ho gaye
  // ============================================================

  Future<void> showRestDayRecommendation({
    required int consecutiveDays,
    required String? muscleGroupWorked,
  }) async {
    await _plugin.show(
      id: _restDayBaseId,
      title: '😴 Rest Day Recommended',
      body:
          'Tumne $consecutiveDays din lagataar workout ki hai'
          '${muscleGroupWorked != null ? ' ($muscleGroupWorked)' : ''}. '
          'Aaj rest karo - recovery bhi training ka hissa hai!',
      notificationDetails: _buildDetails(NotificationChannel.restDayReminder),
      payload: _encodePayload(
        NotificationPayload(
          title: '😴 Rest Day Recommended',
          body: 'Recovery time! $consecutiveDays consecutive days complete.',
          channel: NotificationChannel.restDayReminder,
          data: {'consecutive_days': consecutiveDays},
          actionRoute: '/recovery',
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS UPDATES (Background weekly calculation)
  // ============================================================

  Future<void> showWeeklyProgressUpdate({
    required int workoutsCompleted,
    required int totalMinutes,
    required int caloriesBurned,
    required double weekOverWeekImprovement,
  }) async {
    final isImproved = weekOverWeekImprovement > 0;
    final improvementText = weekOverWeekImprovement.abs().toStringAsFixed(1);

    await _plugin.show(
      id: _progressBaseId,
      title: isImproved ? '📈 Great Week!' : '📊 Weekly Summary',
      body:
          'Is hafte: $workoutsCompleted workouts, $totalMinutes min, $caloriesBurned cal burned.'
          ' ${isImproved ? '+$improvementText% improvement! 🔥' : 'Agli hafte aur mehnat!'}',
      notificationDetails: _buildDetails(NotificationChannel.progressUpdate),
      payload: _encodePayload(
        NotificationPayload(
          title: 'Weekly Progress',
          body: 'View your weekly stats',
          channel: NotificationChannel.progressUpdate,
          data: {
            'workouts': workoutsCompleted,
            'minutes': totalMinutes,
            'calories': caloriesBurned,
          },
          actionRoute: '/progress/weekly',
        ),
      ),
    );
  }

  Future<void> showMonthlyProgressUpdate({
    required int month,
    required int year,
    required Map<String, dynamic> stats,
  }) async {
    final monthName = _getMonthName(month);
    await _plugin.show(
      id: _progressBaseId + 1,
      title: '🏆 $monthName Summary',
      body:
          '${stats['total_workouts']} workouts, ${stats['total_calories']} cal burned. '
          '${stats['best_streak']} din ki best streak!',
      notificationDetails: _buildDetails(NotificationChannel.progressUpdate),
      payload: _encodePayload(
        NotificationPayload(
          title: '$monthName Monthly Summary',
          body: 'View full report',
          channel: NotificationChannel.progressUpdate,
          data: stats,
          actionRoute: '/progress/monthly?month=$month&year=$year',
        ),
      ),
    );
  }

  // ============================================================
  // CANCEL METHODS
  // ============================================================

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  NotificationDetails _buildDetails(NotificationChannel channel) {
    final androidDetails = AndroidNotificationDetails(
      channel.channelId,
      channel.channelName,
      importance: _getImportance(channel),
      priority: _getPriority(channel),
      styleInformation: const BigTextStyleInformation(''),
      enableVibration: _shouldVibrate(channel),
      icon: _getIcon(channel),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Importance _getImportance(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.streakWarning:
      case NotificationChannel.challengeUpdate:
      case NotificationChannel.subscriptionAlert:
        return Importance.high;
      case NotificationChannel.hydrationReminder:
      case NotificationChannel.restDayReminder:
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriority(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.streakWarning:
      case NotificationChannel.subscriptionAlert:
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }

  bool _shouldVibrate(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.hydrationReminder:
      case NotificationChannel.restDayReminder:
      case NotificationChannel.progressUpdate:
        return false;
      default:
        return true;
    }
  }

  String? _getIcon(NotificationChannel channel) {
    // Uses default @mipmap/ic_launcher (set in AndroidInitializationSettings)
    return null;
  }

  tz.TZDateTime _nextWeekdayTime(int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Agle matching weekday tak loop karo
    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextDailyTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  String _encodePayload(NotificationPayload payload) {
    return Uri.encodeFull(payload.toMap().toString());
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }
}

// Background notification handler (top-level function hona chahiye)
@pragma('vm:entry-point')
void backgroundNotificationHandler(NotificationResponse response) {
  // Background mein notification tap handle karo
  developer.log(
    'Background notification tapped: ${response.payload}',
    name: 'Notifications',
  );
}
