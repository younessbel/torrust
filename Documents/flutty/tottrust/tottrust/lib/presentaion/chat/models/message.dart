import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String id; // This will be the _id from MongoDB
  final String sender;
  final String recipient;
  final String senderModel;
  final String recipientModel;
  final String type;
  final String content;
  final DateTime timestamp;
  
  // Static variable to cache the current user ID
  static String? _cachedUserId;

  Message({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.senderModel,
    required this.recipientModel,
    required this.type,
    required this.content,
    required this.timestamp,
  });

  // Static method to initialize the cached user ID
  static Future<void> initializeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedUserId = prefs.getString('userId');
  }

  // Static method to update cached user ID when it changes
  static void updateCachedUserId(String userId) {
    _cachedUserId = userId;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      sender: json['sender'] ?? '',
      recipient: json['recipient'] ?? '',
      senderModel: json['senderModel'] ?? 'mother',
      recipientModel: json['recipientModel'] ?? 'mother',
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'recipient': recipient,
      'senderModel': senderModel,
      'recipientModel': recipientModel,
      'type': type,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    // Use cached user ID instead of the message sender field
    final currentUserId = _cachedUserId ?? 'unknown';
    return 'Message{id: $id, sender: $currentUserId, recipient: $recipient, senderModel: $senderModel, recipientModel: $recipientModel, content: $content}';
  }

  // Alternative: Create a method that shows both the message sender and current user
  @override
  String toStringDetailed() {
    final currentUserId = _cachedUserId ?? 'unknown';
    return 'Message{id: $id, messageSender: $sender, currentUser: $currentUserId, recipient: $recipient, senderModel: $senderModel, recipientModel: $recipientModel, content: $content}';
  }

  // If you need to get fresh data from SharedPreferences
  Future<String> toStringWithFreshUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId') ?? 'unknown';
    return 'Message{id: $id, sender: $currentUserId, recipient: $recipient, senderModel: $senderModel, recipientModel: $recipientModel, content: $content}';
  }
}
