class CrashLogModel {
  final String id;
  final String? userId;
  final String errorType;
  final String errorMessage;
  final String? stackTrace;
  final bool fatal;
  final String source;
  final String? screenRoute;
  final String? platform;
  final String? osVersion;
  final String? appVersion;
  final String? deviceModel;
  final Map<String, dynamic> extraData;
  final DateTime createdAt;

  // Joined user info (from admin queries)
  final String? userName;
  final String? userEmail;
  final String? userAvatar;

  CrashLogModel({
    required this.id,
    this.userId,
    required this.errorType,
    required this.errorMessage,
    this.stackTrace,
    this.fatal = false,
    this.source = 'dart',
    this.screenRoute,
    this.platform,
    this.osVersion,
    this.appVersion,
    this.deviceModel,
    this.extraData = const {},
    required this.createdAt,
    this.userName,
    this.userEmail,
    this.userAvatar,
  });

  factory CrashLogModel.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    return CrashLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      errorType: json['error_type'] as String? ?? 'Unknown',
      errorMessage: json['error_message'] as String? ?? '',
      stackTrace: json['stack_trace'] as String?,
      fatal: json['fatal'] as bool? ?? false,
      source: json['source'] as String? ?? 'dart',
      screenRoute: json['screen_route'] as String?,
      platform: json['platform'] as String?,
      osVersion: json['os_version'] as String?,
      appVersion: json['app_version'] as String?,
      deviceModel: json['device_model'] as String?,
      extraData: (json['extra_data'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: user?['full_name'] as String?,
      userEmail: user?['email'] as String?,
      userAvatar: user?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        if (userId != null) 'user_id': userId,
        'error_type': errorType,
        'error_message': errorMessage,
        if (stackTrace != null) 'stack_trace': stackTrace,
        'fatal': fatal,
        'source': source,
        if (screenRoute != null) 'screen_route': screenRoute,
        if (platform != null) 'platform': platform,
        if (osVersion != null) 'os_version': osVersion,
        if (appVersion != null) 'app_version': appVersion,
        if (deviceModel != null) 'device_model': deviceModel,
        if (extraData.isNotEmpty) 'extra_data': extraData,
      };

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get severityLabel => fatal ? 'Crash' : 'Exception';

  String get shortErrorType {
    // Extract just the class name: "FormatException" from full type
    if (errorType.contains('.')) {
      return errorType.split('.').last;
    }
    return errorType;
  }

  String get displayName => userName ?? 'Anonymous';
}
