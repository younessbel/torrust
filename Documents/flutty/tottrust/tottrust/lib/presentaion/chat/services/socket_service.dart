import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'api_service.dart';
import 'logger_service.dart';

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;

  static SocketService get instance {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  SocketService._internal();

  Future<void> connect() async {
    if (_socket?.connected == true) {
      LoggerService.logInfo(
          '🔌 Socket already connected - skipping connection');
      return;
    }

    LoggerService.logInfo('🔌 Attempting to connect to socket server');

    final token = await ApiService.getToken();
    if (token == null) {
      LoggerService.logError(
          '🔌 No authentication token found for socket connection');
      throw Exception('No authentication token found');
    }

    LoggerService.logDebug(
        '🔌 Creating socket connection with authentication token');

    _socket = IO.io(
        'http://192.168.8.102:4000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({'token': token})
            .build());

    // Setup event listeners before connecting
    _setupEventListeners();

    _socket!.connect();
    LoggerService.logInfo('🔌 Socket connection initiated');
  }

  void _setupEventListeners() {
    LoggerService.logDebug('🔌 Setting up socket event listeners');

    _socket!.onConnect((_) {
      LoggerService.logSuccess('🔌 Successfully connected to socket server');
      LoggerService.logSocketEvent('connect', 'Connection established');
    });

    _socket!.onDisconnect((reason) {
      LoggerService.logWarning(
          '🔌 Disconnected from socket server. Reason: $reason');
      LoggerService.logSocketEvent('disconnect', reason);
    });

    _socket!.onConnectError((error) {
      LoggerService.logError('🔌 Socket connection error', error);
      LoggerService.logSocketEvent('connect_error', error);
    });

    _socket!.onError((error) {
      LoggerService.logError('🔌 Socket error', error);
      LoggerService.logSocketEvent('error', error);
    });

    // Log all socket events for debugging
    _socket!.onAny((event, data) {
      LoggerService.logSocketEvent('ANY_EVENT: $event', data);
    });

    LoggerService.logSuccess('🔌 Socket event listeners configured');
  }

  void disconnect() {
    LoggerService.logInfo('🔌 Disconnecting from socket server');
    _socket?.disconnect();
    _socket = null;
    LoggerService.logSuccess('🔌 Socket disconnected and cleaned up');
  }

  bool get isConnected => _socket?.connected ?? false;

  // Send message
  void sendMessage({
    required String to,
    required String type,
    required String content,
  }) {
    final messageData = {
      'to': to,
      'type': type,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    };

    LoggerService.logInfo('💬 Sending message via socket');
    LoggerService.logUserAction('Send Message', {
      'to': to,
      'type': type,
      'contentLength': content.length,
    });
    LoggerService.logSocketEvent('send-message (OUTGOING)', messageData);

    if (_socket?.connected == true) {
      _socket!.emit('send-message', messageData);
      LoggerService.logSuccess('💬 Message sent successfully');
    } else {
      LoggerService.logError('💬 Cannot send message - socket not connected');
      throw Exception('Socket not connected');
    }
  }

  // Listen for incoming messages
  void onReceiveMessage(Function(Map<String, dynamic>) callback) {
    LoggerService.logDebug('💬 Setting up receive-message listener');
    _socket?.on('receive-message', (data) {
      LoggerService.logSocketEvent('receive-message (INCOMING)', data);
      LoggerService.logInfo('💬 New message received from: ${data['from']}');
      callback(data);
    });
  }

  // Video call methods
  void callUser(
      {required String calleeId, required Map<String, dynamic> offer}) {
    final callData = {
      'calleeId': calleeId,
      'offer': offer,
      'timestamp': DateTime.now().toIso8601String(),
    };

    LoggerService.logInfo('📹 Initiating video call to: $calleeId');
    LoggerService.logUserAction('Start Video Call', {'calleeId': calleeId});
    LoggerService.logSocketEvent('call-user (OUTGOING)', callData);

    if (_socket?.connected == true) {
      _socket!.emit('call-user', callData);
      LoggerService.logSuccess('📹 Video call initiated');
    } else {
      LoggerService.logError('📹 Cannot initiate call - socket not connected');
    }
  }

  void answerCall(
      {required String callerId, required Map<String, dynamic> answer}) {
    final answerData = {
      'callerId': callerId,
      'answer': answer,
      'timestamp': DateTime.now().toIso8601String(),
    };

    LoggerService.logInfo('📹 Answering video call from: $callerId');
    LoggerService.logUserAction('Answer Video Call', {'callerId': callerId});
    LoggerService.logSocketEvent('answer-call (OUTGOING)', answerData);

    if (_socket?.connected == true) {
      _socket!.emit('answer-call', answerData);
      LoggerService.logSuccess('📹 Call answered');
    } else {
      LoggerService.logError('📹 Cannot answer call - socket not connected');
    }
  }

  void sendIceCandidate(
      {required String targetId, required Map<String, dynamic> candidate}) {
    final candidateData = {
      'targetId': targetId,
      'candidate': candidate,
      'timestamp': DateTime.now().toIso8601String(),
    };

    LoggerService.logDebug('📹 Sending ICE candidate to: $targetId');
    LoggerService.logSocketEvent(
        'send-ice-candidate (OUTGOING)', candidateData);

    if (_socket?.connected == true) {
      _socket!.emit('send-ice-candidate', candidateData);
    } else {
      LoggerService.logError(
          '📹 Cannot send ICE candidate - socket not connected');
    }
  }

  // Listen for incoming calls
  void onIncomingCall(Function(Map<String, dynamic>) callback) {
    LoggerService.logDebug('📹 Setting up incoming-call listener');
    _socket?.on('incoming-call', (data) {
      LoggerService.logSocketEvent('incoming-call (INCOMING)', data);
      LoggerService.logInfo('📹 Incoming call from: ${data['from']}');
      callback(data);
    });
  }

  void onCallAnswered(Function(Map<String, dynamic>) callback) {
    LoggerService.logDebug('📹 Setting up call-answered listener');
    _socket?.on('call-answered', (data) {
      LoggerService.logSocketEvent('call-answered (INCOMING)', data);
      LoggerService.logInfo('📹 Call answered by: ${data['from']}');
      callback(data);
    });
  }

  void onIceCandidate(Function(Map<String, dynamic>) callback) {
    LoggerService.logDebug('📹 Setting up ice-candidate listener');
    _socket?.on('ice-candidate', (data) {
      LoggerService.logSocketEvent('ice-candidate (INCOMING)', data);
      LoggerService.logDebug('📹 ICE candidate received from: ${data['from']}');
      callback(data);
    });
  }

  // Send file
  void sendFile({
    required String to,
    required String type,
    required String content,
  }) {
    final fileData = {
      'to': to,
      'type': type,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    };

    LoggerService.logInfo('📎 Sending file via socket');
    LoggerService.logUserAction('Send File', {
      'to': to,
      'type': type,
      'size': content.length,
    });
    LoggerService.logSocketEvent('send-file (OUTGOING)', fileData);

    if (_socket?.connected == true) {
      _socket!.emit('send-file', fileData);
      LoggerService.logSuccess('📎 File sent successfully');
    } else {
      LoggerService.logError('📎 Cannot send file - socket not connected');
    }
  }

  void onReceiveFile(Function(Map<String, dynamic>) callback) {
    LoggerService.logDebug('📎 Setting up receive-file listener');
    _socket?.on('receive-file', (data) {
      LoggerService.logSocketEvent('receive-file (INCOMING)', data);
      LoggerService.logInfo('📎 File received from: ${data['from']}');
      callback(data);
    });
  }

  void onError(Function(Map<String, dynamic>) callback) {
    LoggerService.logDebug('❌ Setting up error listener');
    _socket?.on('error', (data) {
      LoggerService.logSocketEvent('error (INCOMING)', data);
      LoggerService.logError('🔌 Socket error received', data);
      callback(data);
    });
  }

  // Get connection status
  String getConnectionStatus() {
    if (_socket == null) return 'Not initialized';
    if (_socket!.connected) return 'Connected';
    if (_socket!.disconnected) return 'Disconnected';
    return 'Unknown';
  }
}
