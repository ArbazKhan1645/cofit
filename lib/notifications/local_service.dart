// ============================================================
// local_notification_service.dart
// Sirf local notifications - schedules, reminders, background
// calculations se triggered hone wale notifications
// ============================================================

import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:cofit_collective/notifications/types.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
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
    if (!_initialized) {
      await initialize();
    }
    try {
      NotificationDetails details;
      if (payload.imageUrl != null && payload.imageUrl!.isNotEmpty) {
        details = await _buildDetailsWithImage(
            payload.channel, payload.imageUrl!);
      } else {
        details = _buildDetails(payload.channel);
      }

      await _plugin.show(
        id: id,
        title: payload.title,
        body: payload.body,
        notificationDetails: details,
        payload: _encodePayload(payload),
      );
    } catch (e) {
      developer.log('Failed to show notification: $e',
          name: 'Notifications', level: 900);
    }
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
  // DAILY SCHEDULED NOTIFICATIONS (7 days — random times)
  // Login/init par schedule hoti hain — har baar reschedule
  // ============================================================

  static const int _dailyScheduledBaseId = 7000;

  // Workout reminder messages
  static const List<Map<String, String>> _workoutMessages = [
    {
      'title': 'Time to Move!',
      'body': 'Your workout is waiting! Even 15 minutes makes a difference.',
    },
    {
      'title': 'Workout Reminder',
      'body': 'Don\'t skip today! Consistency is the key to results.',
    },
    {
      'title': 'Let\'s Get Moving!',
      'body': 'Your body will thank you! Open CoFit and start your session.',
    },
    {
      'title': 'Today\'s Workout Awaits',
      'body': 'You\'re one workout closer to your goals. Let\'s go!',
    },
    {
      'title': 'Fitness Check-In',
      'body': 'Have you done your workout today? Your streak depends on it!',
    },
    {
      'title': 'Crush It Today!',
      'body': 'No excuses! Open the app and get your sweat on.',
    },
    {
      'title': 'Your Muscles Are Calling',
      'body': 'They want to grow! Give them a reason to — workout now.',
    },
  ];

  // Random greeting / motivation messages
  static const List<Map<String, String>> _greetingMessages = [
    {
      'title': 'Hey Queen!',
      'body': 'You\'re doing amazing! Keep showing up for yourself.',
    },
    {
      'title': 'Good Vibes Only',
      'body': 'Remember: progress, not perfection. You\'ve got this!',
    },
    {
      'title': 'Stay Strong!',
      'body': 'Every step counts. Your future self will thank you.',
    },
    {
      'title': 'You\'re a Warrior!',
      'body': 'The hardest part is starting. Everything else is momentum.',
    },
    {
      'title': 'Believe in Yourself',
      'body': 'You\'re stronger than you think. CoFit believes in you!',
    },
    {
      'title': 'Self-Care Reminder',
      'body': 'Taking care of your body is the best investment. Keep going!',
    },
    {
      'title': 'Fitness is a Journey',
      'body': 'Not a destination. Enjoy every rep, every stretch, every step.',
    },
    {
      'title': 'Hello Sunshine!',
      'body': 'A healthy body = a happy mind. Move a little today!',
    },
    {
      'title': 'You\'re Glowing!',
      'body': 'Keep up the amazing work. Your consistency is inspiring!',
    },
    {
      'title': 'Daily Dose of Motivation',
      'body': 'Champions aren\'t made in gyms — they\'re made from something deep inside. Let\'s go!',
    },
  ];

  /// Schedule random notifications for the next 7 days
  /// Called on login/init — cancels old ones and reschedules fresh
  Future<void> scheduleNext7DaysNotifications() async {
    if (!_initialized) await initialize();

    // Cancel old daily scheduled notifications
    await _cancelDailyScheduled();

    final random = Random();
    final now = tz.TZDateTime.now(tz.local);
    final storage = GetStorage();

    // Check if already scheduled today — avoid duplicate scheduling on app restart
    final lastScheduled = storage.read<String>('last_notif_schedule_date');
    final todayStr = '${now.year}-${now.month}-${now.day}';
    if (lastScheduled == todayStr) {
      developer.log(
        'Daily notifications already scheduled today — skipping',
        name: 'Notifications',
      );
      return;
    }

    int notifIndex = 0;

    for (int day = 0; day < 7; day++) {
      final targetDate = now.add(Duration(days: day + 1));

      // Random time between 8:00 AM and 8:00 PM
      final hour = 8 + random.nextInt(12); // 8-19
      final minute = random.nextInt(60); // 0-59

      final scheduledTime = tz.TZDateTime(
        tz.local,
        targetDate.year,
        targetDate.month,
        targetDate.day,
        hour,
        minute,
      );

      // Skip if time is in the past (edge case for today)
      if (scheduledTime.isBefore(now)) continue;

      // Pick random message — alternate between workout & greeting
      final Map<String, String> message;
      final NotificationChannel channel;

      if (day.isEven) {
        // Workout reminder
        message = _workoutMessages[random.nextInt(_workoutMessages.length)];
        channel = NotificationChannel.workoutReminder;
      } else {
        // Motivational greeting
        message = _greetingMessages[random.nextInt(_greetingMessages.length)];
        channel = NotificationChannel.dailyGoalReminder;
      }

      try {
        await _plugin.zonedSchedule(
          id: _dailyScheduledBaseId + notifIndex,
          title: message['title'],
          body: message['body'],
          scheduledDate: scheduledTime,
          notificationDetails: _buildDetails(channel),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: _encodePayload(
            NotificationPayload(
              title: message['title']!,
              body: message['body']!,
              channel: channel,
              actionRoute: '/home',
            ),
          ),
        );
        notifIndex++;
      } catch (e) {
        developer.log(
          'Failed to schedule notification for day $day: $e',
          name: 'Notifications',
          level: 900,
        );
      }
    }

    // Save today's date so we don't re-schedule on every app restart
    await storage.write('last_notif_schedule_date', todayStr);

    developer.log(
      'Scheduled $notifIndex notifications for next 7 days',
      name: 'Notifications',
    );
  }

  Future<void> _cancelDailyScheduled() async {
    for (int i = 0; i < 14; i++) {
      await _plugin.cancel(id: _dailyScheduledBaseId + i);
    }
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

  Future<NotificationDetails> _buildDetailsWithImage(
    NotificationChannel channel,
    String imageUrl,
  ) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final androidDetails = AndroidNotificationDetails(
          channel.channelId,
          channel.channelName,
          importance: _getImportance(channel),
          priority: _getPriority(channel),
          styleInformation: BigPictureStyleInformation(
            ByteArrayAndroidBitmap(bytes),
            hideExpandedLargeIcon: true,
          ),
          enableVibration: _shouldVibrate(channel),
          icon: _getIcon(channel),
        );

        // iOS — save to temp file for attachment
        DarwinNotificationDetails iosDetails;
        try {
          final tempDir = Directory.systemTemp;
          final filePath =
              '${tempDir.path}/notif_img_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await File(filePath).writeAsBytes(bytes);
          iosDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            attachments: [DarwinNotificationAttachment(filePath)],
          );
        } catch (_) {
          iosDetails = const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
        }

        return NotificationDetails(android: androidDetails, iOS: iosDetails);
      }
    } catch (e) {
      developer.log('Failed to download notification image: $e',
          name: 'Notifications', level: 900);
    }
    // Fallback to no-image details
    return _buildDetails(channel);
  }

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
