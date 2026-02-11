import 'community_model.dart';

/// Support Ticket Model
/// Supabase Table: support_tickets
class SupportTicketModel {
  final String id;
  final String userId;
  final String subject;
  final String status; // open, in_progress, resolved, closed
  final String priority; // low, normal, high, urgent
  final String? screenReference;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final UserSummary? user;
  final TicketMessageModel? lastMessage;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.subject,
    this.status = 'open',
    this.priority = 'normal',
    this.screenReference,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.lastMessage,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    // Handle last message from joined ticket_messages
    TicketMessageModel? lastMsg;
    if (json['ticket_messages'] != null) {
      final msgs = json['ticket_messages'] as List<dynamic>;
      if (msgs.isNotEmpty) {
        lastMsg = TicketMessageModel.fromJson(msgs.last as Map<String, dynamic>);
      }
    }

    return SupportTicketModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subject: json['subject'] as String,
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as String? ?? 'normal',
      screenReference: json['screen_reference'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['users'] != null
          ? UserSummary.fromJson(json['users'] as Map<String, dynamic>)
          : null,
      lastMessage: lastMsg,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'subject': subject,
      'priority': priority,
      if (screenReference != null) 'screen_reference': screenReference,
    };
  }

  SupportTicketModel copyWith({
    String? id,
    String? userId,
    String? subject,
    String? status,
    String? priority,
    String? screenReference,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserSummary? user,
    TicketMessageModel? lastMessage,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      screenReference: screenReference ?? this.screenReference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  // Status helpers
  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
  bool get isActive => isOpen || isInProgress;

  String get statusLabel {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'normal':
        return 'Normal';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);

    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Ticket Message Model
/// Supabase Table: ticket_messages
class TicketMessageModel {
  final String id;
  final String ticketId;
  final String senderId;
  final String message;
  final bool isAdmin;
  final DateTime createdAt;

  // Joined data
  final UserSummary? sender;

  TicketMessageModel({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.message,
    this.isAdmin = false,
    required this.createdAt,
    this.sender,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      sender: json['users'] != null
          ? UserSummary.fromJson(json['users'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'ticket_id': ticketId,
      'sender_id': senderId,
      'message': message,
      'is_admin': isAdmin,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
