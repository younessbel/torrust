import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/logger_service.dart';
import '../services/socket_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String contactId;
  final String contactName;

  const VideoCallScreen({
    super.key,
    required this.contactId,
    required this.contactName,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _videoOff = false;
  bool _micMuted = false;
  bool _isInCall = false;
  Timer? _callTimer;
  int _seconds = 0;

  String get _callTime =>
      "${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    LoggerService.logInfo('📹 VideoCallScreen initialized');
    LoggerService.logNavigation(
        'ChatScreen', 'VideoCallScreen(${widget.contactName})');
    LoggerService.logUserAction('Start Video Call', {
      'contactId': widget.contactId,
      'contactName': widget.contactName,
    });
    _initCamera();
    _setupWebRTCListeners();
    _startCall();
  }

  Future<void> _initCamera() async {
    LoggerService.logInfo('📹 Initializing camera');

    try {
      final cameraPermission = await Permission.camera.request();
      final micPermission = await Permission.microphone.request();

      LoggerService.logDebug('📹 Camera permission: $cameraPermission');
      LoggerService.logDebug('📹 Microphone permission: $micPermission');

      if (cameraPermission != PermissionStatus.granted) {
        LoggerService.logError('📹 Camera permission denied');
        return;
      }

      final cameras = await availableCameras();
      LoggerService.logDebug('📹 Available cameras: ${cameras.length}');

      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      LoggerService.logDebug('📹 Using camera: ${frontCamera.name}');

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      LoggerService.logSuccess('📹 Camera initialized successfully');
    } catch (e, stackTrace) {
      LoggerService.logError('📹 Camera initialization failed', e, stackTrace);
    }
  }

  void _setupWebRTCListeners() {
    LoggerService.logDebug('📹 Setting up WebRTC listeners');

    SocketService.instance.onIncomingCall((data) {
      LoggerService.logInfo('📹 Incoming call received');
      LoggerService.logSocketEvent('incoming-call', data);
    });

    SocketService.instance.onCallAnswered((data) {
      LoggerService.logInfo('📹 Call answered');
      LoggerService.logSocketEvent('call-answered', data);
      setState(() {
        _isInCall = true;
      });
      _startTimer();
    });

    SocketService.instance.onIceCandidate((data) {
      LoggerService.logDebug('📹 ICE candidate received');
      LoggerService.logSocketEvent('ice-candidate', data);
    });
  }

  void _startCall() {
    LoggerService.logInfo('📹 Starting video call');

    final mockOffer = {
      'type': 'offer',
      'sdp': 'mock-sdp-data-${DateTime.now().millisecondsSinceEpoch}',
    };

    try {
      SocketService.instance.callUser(
        calleeId: widget.contactId,
        offer: mockOffer,
      );
      LoggerService.logSuccess('📹 Call initiated successfully');
    } catch (e) {
      LoggerService.logError('📹 Failed to initiate call', e);
    }

    // Simulate call connection for demo
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        LoggerService.logInfo('📹 Simulating call connection');
        setState(() {
          _isInCall = true;
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    LoggerService.logDebug('📹 Starting call timer');
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });

        // Log call duration every minute
        if (_seconds % 60 == 0) {
          LoggerService.logInfo(
              '📹 Call duration: ${_seconds ~/ 60} minute(s)');
        }
      }
    });
  }

  void _endCall() {
    LoggerService.logInfo('📹 Ending video call');
    LoggerService.logUserAction('End Video Call', {
      'duration': _callTime,
      'durationSeconds': _seconds,
    });

    _callTimer?.cancel();
    LoggerService.logNavigation('VideoCallScreen', 'ChatScreen');
    Navigator.pop(context);
  }

  void _toggleMic() {
    setState(() {
      _micMuted = !_micMuted;
    });
    LoggerService.logUserAction('Toggle Microphone', {'muted': _micMuted});
    LoggerService.logDebug('📹 Microphone ${_micMuted ? 'muted' : 'unmuted'}');
  }

  void _toggleVideo() {
    setState(() {
      _videoOff = !_videoOff;
    });
    LoggerService.logUserAction('Toggle Video', {'videoOff': _videoOff});
    LoggerService.logDebug(
        '📹 Video ${_videoOff ? 'turned off' : 'turned on'}');
  }

  @override
  void dispose() {
    LoggerService.logInfo('📹 VideoCallScreen disposing');
    LoggerService.logDebug('📹 Final call duration: $_callTime');
    _cameraController?.dispose();
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LoggerService.logDebug(
        '🎨 Building VideoCallScreen UI - InCall: $_isInCall, VideoOff: $_videoOff, MicMuted: $_micMuted');
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  const NetworkImage("https://i.pravatar.cc/150?img=3"),
              radius: 16,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contactName,
                  style: GoogleFonts.mochiyPopOne(fontSize: 14),
                ),
                Text(
                  _isInCall ? _callTime : 'Connecting...',
                  style: GoogleFonts.mochiyPopOne(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _endCall,
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: _isInitialized && !_videoOff
                ? CameraPreview(_cameraController!)
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: const Icon(
                      Icons.videocam_off,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
          ),

          if (!_isInCall)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 50),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Calling ${widget.contactName}...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mochiyPopOne(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

          // Call controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton(
                  icon: _micMuted ? Icons.mic_off : Icons.mic,
                  color: _micMuted ? Colors.red : Colors.white,
                  onPressed: _toggleMic,
                ),
                _controlButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onPressed: _endCall,
                ),
                _controlButton(
                  icon: _videoOff ? Icons.videocam_off : Icons.videocam,
                  color: _videoOff ? Colors.red : Colors.white,
                  onPressed: _toggleVideo,
                ),
              ],
            ),
          ),

          // Debug info overlay (only in debug mode)
          Positioned(
            top: 100,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Socket: ${SocketService.instance.getConnectionStatus()}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Camera: ${_isInitialized ? 'Ready' : 'Loading'}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Call: ${_isInCall ? 'Active' : 'Connecting'}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.black54,
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
