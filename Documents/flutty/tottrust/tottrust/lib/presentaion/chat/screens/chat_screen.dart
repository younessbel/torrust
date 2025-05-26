import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/message.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';
import '../services/socket_service.dart';
import 'video_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String contactId;
  final String? name;
  final String? imageUrl;

  const ChatScreen({
    super.key,
    required this.contactId,
    required this.name,
    this.imageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  String? _currentUserId;
  int _messageCount = 0;
  bool _isSocketConnected = false;

  @override
  void initState() {
    super.initState();
    LoggerService.logInfo('💬 ChatScreen initialized');
    LoggerService.logNavigation('ChatHomeScreen', 'ChatScreen(${widget.name})');
    LoggerService.logDebug(
        '💬 Contact details: ID=${widget.contactId}, Name=${widget.name}');
    _initializeChat();
    _setupSocketListeners();
  }

  Future<void> _initializeChat() async {
    LoggerService.logInfo('💬 Initializing chat');
    await _getCurrentUserId();
    await _ensureSocketConnection();
    await _loadPreviousMessages();
  }

  Future<void> _getCurrentUserId() async {
    LoggerService.logDebug('👤 Getting current user ID');
    _currentUserId = await ApiService.getCurrentUserId();

    if (_currentUserId == null || _currentUserId!.isEmpty) {
      LoggerService.logWarning(
          '👤 No current user ID found, initializing user session');
      await ApiService.initializeUserSession();
      _currentUserId = await ApiService.getCurrentUserId();
    }

    LoggerService.logInfo('👤 ✅ Current user ID set to: "$_currentUserId"');

    if (_currentUserId == null || _currentUserId!.isEmpty) {
      // Last resort: create a temporary user ID
      _currentUserId = 'temp-user-${DateTime.now().millisecondsSinceEpoch}';
      await ApiService.setCurrentUserId(_currentUserId!);
      LoggerService.logWarning('👤 Created temporary user ID: $_currentUserId');
    }
  }

  Future<void> _ensureSocketConnection() async {
    LoggerService.logDebug('🔌 Ensuring socket connection');
    try {
      if (!SocketService.instance.isConnected) {
        LoggerService.logInfo('🔌 Socket not connected, attempting to connect');
        await SocketService.instance.connect();
      }

      setState(() {
        _isSocketConnected = SocketService.instance.isConnected;
      });

      LoggerService.logSuccess(
          '🔌 Socket connection status: $_isSocketConnected');
    } catch (e) {
      LoggerService.logError('🔌 Socket connection failed', e);
      setState(() {
        _isSocketConnected = false;
      });
    }
  }

  Future<void> _loadPreviousMessages() async {
    try {
      LoggerService.logInfo(
          '💬 Loading previous messages for contact: ${widget.contactId}');
      setState(() => _isLoading = true);

      // IMPORTANT: Ensure we have current user ID before loading messages
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        LoggerService.logWarning(
            '💬 No current user ID available, getting it first...');
        await _getCurrentUserId();
      }

      LoggerService.logInfo(
          '💬 Using current user ID for comparison: "$_currentUserId"');

      final stopwatch = Stopwatch()..start();

      try {
        // Use the correct API endpoint format: /messages/:user1Id/:user2Id
        final messages =
            await ApiService.loadMessages(_currentUserId!, widget.contactId);

        // Sort messages by timestamp to ensure proper order
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        setState(() {
          _messages = messages;
          _messageCount = messages.length;
        });

        LoggerService.logSuccess(
            '💬 Previous messages loaded: ${messages.length} messages in ${stopwatch.elapsedMilliseconds}ms');

        // IMPORTANT: Log each message to debug positioning
        LoggerService.logInfo('💬 ========================================');
        LoggerService.logInfo('💬 📊 MESSAGE POSITIONING ANALYSIS');
        LoggerService.logInfo('💬 ========================================');
        LoggerService.logInfo('💬 Current User ID: "$_currentUserId"');
        LoggerService.logInfo('💬 Contact ID: "${widget.contactId}"');
        LoggerService.logInfo('💬 Total Messages: ${messages.length}');
        LoggerService.logInfo('💬 ========================================');

        int rightCount = 0;
        int leftCount = 0;

        for (int i = 0; i < messages.length; i++) {
          final msg = messages[i];
          final isSentByMe = _isMessageSentByCurrentUser(msg);
          final position =
              isSentByMe ? '➡️ RIGHT (SENT BY ME)' : '⬅️ LEFT (RECEIVED)';

          if (isSentByMe)
            rightCount++;
          else
            leftCount++;

          LoggerService.logInfo('💬 Message ${i + 1}: $position');
          LoggerService.logInfo('💬   📝 Content: "${msg.content}"');
          LoggerService.logInfo('💬   👤 Sender: "${msg.sender}"');
          LoggerService.logInfo('💬   📨 Recipient: "${msg.recipient}"');
          LoggerService.logInfo(
              '💬   🔍 Sender == CurrentUser: ${msg.sender == _currentUserId}');
          LoggerService.logInfo('💬   ⏰ Timestamp: ${msg.timestamp}');
          LoggerService.logInfo('💬   ---');
        }

        LoggerService.logInfo('💬 ========================================');
        LoggerService.logInfo(
            '💬 📈 SUMMARY: $rightCount RIGHT, $leftCount LEFT');
        LoggerService.logInfo('💬 ========================================');
      } catch (e) {
        LoggerService.logWarning('💬 Could not load previous messages: $e');
        // Don't create demo messages, just show empty state
        setState(() {
          _messages = [];
          _messageCount = 0;
        });
      }

      stopwatch.stop();
      setState(() => _isLoading = false);
      _scrollToBottom();
    } catch (e, stackTrace) {
      LoggerService.logError(
          '💬 Failed to load previous messages', e, stackTrace);
      setState(() {
        _isLoading = false;
        _messages = [];
        _messageCount = 0;
      });
    }
  }

  // Helper method to determine if message was sent by current user
  bool _isMessageSentByCurrentUser(Message message) {
    // Handle null or empty values
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      LoggerService.logError('💬 ❌ Current user ID is null or empty!');
      return false; // Default to LEFT side if no current user
    }

    if (message.sender.isEmpty) {
      LoggerService.logError('💬 ❌ Message sender is empty!');
      return false; // Default to LEFT side if no sender
    }

    // Clean and normalize both IDs for comparison
    final messageSender = message.sender.toString().trim();
    final currentUser = _currentUserId!.toString().trim();

    // Perform exact string comparison
    final isSentByMe = messageSender == currentUser;

    // Detailed logging for debugging
    LoggerService.logInfo('💬 === MESSAGE OWNERSHIP CHECK ===');
    LoggerService.logInfo('💬 Message Content: "${message.content}"');
    LoggerService.logInfo(
        '💬 Message Sender: "$messageSender" (length: ${messageSender.length})');
    LoggerService.logInfo(
        '💬 Current User:   "$currentUser" (length: ${currentUser.length})');
    LoggerService.logInfo('💬 Are Equal:      $isSentByMe');
    LoggerService.logInfo(
        '💬 Position:       ${isSentByMe ? '➡️ RIGHT (SENT BY ME)' : '⬅️ LEFT (RECEIVED)'}');
    LoggerService.logInfo('💬 === END CHECK ===');

    return isSentByMe;
  }

  void _setupSocketListeners() {
    LoggerService.logDebug('🔌 Setting up socket listeners for chat');

    SocketService.instance.onReceiveMessage((data) {
      LoggerService.logInfo('💬 Received new message via socket');
      LoggerService.logDebug('💬 Socket message data: $data');

      // Message received via socket is always FROM someone else TO current user (LEFT side)
      final message = Message(
        id: data['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        sender: data['sender'] ??
            data['from'] ??
            widget.contactId, // Contact is sender
        recipient: data['recipient'] ??
            _currentUserId ??
            '', // Current user is recipient
        senderModel: data['senderModel'] ?? 'babysitter',
        recipientModel: data['recipientModel'] ?? 'mother',
        type: data['type'] ?? 'text',
        content: data['content'] ?? '',
        timestamp: data['timestamp'] != null
            ? DateTime.parse(data['timestamp'])
            : DateTime.now(),
      );

      setState(() {
        _messages.add(message);
        _messageCount++;
      });

      LoggerService.logSuccess(
          '💬 Received message added to LEFT side: ${message.content}');
      LoggerService.logDebug(
          '💬 Socket message schema: _id=${message.id}, sender=${message.sender}, recipient=${message.recipient}');
      _scrollToBottom();
    });

    SocketService.instance.onError((data) {
      LoggerService.logError('🔌 Socket error in chat', data);
      setState(() {
        _isSocketConnected = false;
      });
      _showError(data['message'] ?? 'Socket connection error occurred');
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      LoggerService.logWarning('💬 Attempted to send empty message');
      return;
    }

    if (_currentUserId == null) {
      LoggerService.logError('💬 Cannot send message - no current user ID');
      _showError('User not authenticated');
      return;
    }

    LoggerService.logInfo('💬 Sending message');
    LoggerService.logUserAction('Send Message', {
      'to': widget.contactId,
      'contentLength': text.length,
      'messageNumber': _messageCount + 1,
      'socketConnected': _isSocketConnected,
    });

    // Create message using your schema format
    // FROM current user TO contact (will appear on RIGHT side)
    final message = Message(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by MongoDB _id
      sender: _currentUserId!, // Current user is sender (RIGHT side)
      recipient: widget.contactId, // Contact is recipient
      senderModel: 'mother', // Adjust based on current user type
      recipientModel: 'babysitter', // Adjust based on contact type
      type: 'text',
      content: text,
      timestamp: DateTime.now(),
    );

    // Add message to UI immediately (will appear on RIGHT side)
    setState(() {
      _messages.add(message);
      _messageCount++;
    });

    LoggerService.logSuccess(
        '💬 Sent message added to RIGHT side: ${message.content}');
    LoggerService.logDebug(
        '💬 Sent message schema: _id=${message.id}, sender=${message.sender}, recipient=${message.recipient}');

    // Try to send via socket if connected
    if (_isSocketConnected) {
      try {
        SocketService.instance.sendMessage(
          to: widget.contactId,
          type: 'text',
          content: text,
        );
        LoggerService.logSuccess('💬 Message sent via socket successfully');
      } catch (e) {
        LoggerService.logError('💬 Failed to send message via socket', e);
        _showError('Failed to send message via socket, but saved locally');
      }
    } else {
      LoggerService.logWarning(
          '💬 Socket not connected, message saved locally only');
      _showError('Message saved locally - socket not connected');
    }

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    LoggerService.logError('💬 Showing error to user: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry Connection',
          textColor: Colors.white,
          onPressed: () {
            LoggerService.logUserAction('Retry Socket Connection');
            _ensureSocketConnection();
          },
        ),
      ),
    );
  }

  // Add this method to help debug user ID issues
  Future<void> _debugCurrentUserId() async {
    LoggerService.logInfo('🔍 === DEBUG CURRENT USER ID ===');

    // Check SharedPreferences directly
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    final storedToken = prefs.getString('accessToken');
    print("dsfs$storedToken");
    LoggerService.logInfo('🔍 Stored User ID: "$storedUserId"');
    LoggerService.logInfo(
        '🔍 Stored Token: "${storedToken?.substring(0, 10) ?? 'null'}..."');
    LoggerService.logInfo('🔍 Current _currentUserId: "$_currentUserId"');
    LoggerService.logInfo('🔍 Contact ID: "${widget.contactId}"');

    // Try to get from API service
    final apiUserId = await ApiService.getCurrentUserId();
    LoggerService.logInfo('🔍 API Service User ID: "$apiUserId"');

    LoggerService.logInfo('🔍 === END DEBUG ===');
  }

  @override
  Widget build(BuildContext context) {
    LoggerService.logDebug(
        '🎨 Building ChatScreen UI - Messages: $_messageCount, Loading: $_isLoading, Socket: $_isSocketConnected');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFE0FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            LoggerService.logUserAction('Back Button Pressed');
            LoggerService.logNavigation('ChatScreen', 'ChatHomeScreen');
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.imageUrl != null
                  ? NetworkImage(widget.imageUrl!)
                  : null,
              backgroundColor: const Color(0xFFE0ECFF),
              child: widget.imageUrl == null
                  ? Icon(
                      Icons.person,
                      color: Colors.blue.shade700,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name ?? "Contact",
                    style: GoogleFonts.mochiyPopOne(
                      color: Colors.blue[900],
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isSocketConnected ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_messageCount} messages • ${_isSocketConnected ? 'Online' : 'Offline'}',
                        style: GoogleFonts.mochiyPopOne(
                          color: Colors.blue[700],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Debug button to show current user ID
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.blue),
            onPressed: () async {
              LoggerService.logUserAction('Debug Info Requested');
              await _debugCurrentUserId(); // Call our debug method

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Debug Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current User ID: "$_currentUserId"'),
                      Text('Contact ID: "${widget.contactId}"'),
                      Text('Messages: $_messageCount'),
                      Text(
                          'Socket: ${_isSocketConnected ? 'Connected' : 'Disconnected'}'),
                      const SizedBox(height: 10),
                      const Text('Message Breakdown:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          'Right (Sent): ${_messages.where((m) => _isMessageSentByCurrentUser(m)).length}'),
                      Text(
                          'Left (Received): ${_messages.where((m) => !_isMessageSentByCurrentUser(m)).length}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadPreviousMessages(); // Reload messages for testing
                      },
                      child: const Text('Reload Messages'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isSocketConnected ? Icons.wifi : Icons.wifi_off,
              color: _isSocketConnected ? Colors.green : Colors.red,
            ),
            onPressed: () {
              LoggerService.logUserAction('Connection Status Checked');
              _ensureSocketConnection();
            },
          ),
          IconButton(
            icon: const Icon(Icons.video_call, color: Colors.blue),
            onPressed: () {
              LoggerService.logUserAction('Video Call Button Pressed');
              LoggerService.logNavigation('ChatScreen', 'VideoCallScreen');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoCallScreen(
                    contactId: widget.contactId,
                    contactName: widget.name ?? "Contact",
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          if (!_isSocketConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.warning_amber,
                      color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Messages will be saved locally until connection is restored',
                      style: GoogleFonts.mochiyPopOne(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _ensureSocketConnection,
                    child: Text(
                      'Retry',
                      style: GoogleFonts.mochiyPopOne(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF7FA9E9),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading messages...',
                          style: TextStyle(
                            color: Color(0xFF7FA9E9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: GoogleFonts.mochiyPopOne(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: GoogleFonts.mochiyPopOne(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) =>
                            _buildMessageBubble(_messages[i], i),
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, int index) {
    // CRITICAL: Use the fixed method to determine message positioning
    final isSentByMe = _isMessageSentByCurrentUser(message);
    final timeFormat = DateFormat('HH:mm');

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isSentByMe
              ? const Color(0xFF7FA9E9) // Blue for messages sent by me (RIGHT)
              : Colors
                  .grey[300], // Grey for messages received from contact (LEFT)
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Show sender info for received messages (LEFT side)
            if (!isSentByMe) ...[
              Text(
                widget.name ?? 'Contact',
                style: GoogleFonts.mochiyPopOne(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
            ],

            Text(
              message.content,
              style: GoogleFonts.mochiyPopOne(
                color: isSentByMe ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeFormat.format(message.timestamp),
                  style: GoogleFonts.mochiyPopOne(
                    fontSize: 10,
                    color: isSentByMe ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '#${index + 1}',
                  style: GoogleFonts.mochiyPopOne(
                    fontSize: 8,
                    color: isSentByMe ? Colors.white60 : Colors.grey[500],
                  ),
                ),
                // Show delivery status for sent messages
                if (isSentByMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _isSocketConnected ? Icons.check : Icons.schedule,
                    size: 12,
                    color: Colors.white70,
                  ),
                ],
                // Enhanced debug info showing exact IDs
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSentByMe ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isSentByMe ? 'ME' : 'THEM',
                    style: GoogleFonts.mochiyPopOne(
                      fontSize: 6,
                      color: isSentByMe ? Colors.white70 : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.mochiyPopOne(color: Colors.black),
              decoration: InputDecoration(
                hintText: _isSocketConnected
                    ? 'Type a message...'
                    : 'Type a message (offline mode)...',
                hintStyle: GoogleFonts.mochiyPopOne(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: !_isSocketConnected
                    ? Icon(Icons.wifi_off,
                        color: Colors.orange.shade600, size: 16)
                    : null,
              ),
              onSubmitted: (_) => _sendMessage(),
              onChanged: (text) {
                // Log typing activity (optional)
                if (text.length % 10 == 0 && text.isNotEmpty) {
                  LoggerService.logDebug(
                      '💬 User typing: ${text.length} characters');
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: _isSocketConnected
                ? const Color(0xFF2D5F9A)
                : Colors.orange.shade600,
            child: IconButton(
              icon: Icon(
                _isSocketConnected ? Icons.send : Icons.save,
                color: Colors.white,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    LoggerService.logInfo('💬 ChatScreen disposing');
    LoggerService.logDebug('💬 Final message count: $_messageCount');
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
