import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/contact.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';
import '../services/socket_service.dart';
import 'chat_screen.dart';

class ChatHomeScreen extends StatefulWidget {
  final String userType; // 'mother' or 'babysitter'

  const ChatHomeScreen({super.key, required this.userType});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen>
    with TickerProviderStateMixin {
  List<Contact> _contacts = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    await _initializeSocket();
    await _ensureUserSession();
    await _loadContacts();
    _animationController.forward();
  }

  Future<void> _initializeSocket() async {
    try {
      await SocketService.instance.connect();
    } catch (e, stackTrace) {
      LoggerService.logError('🔌 Socket connection failed', e, stackTrace);
    }
  }

  Future<void> _ensureUserSession() async {
    try {
      await ApiService.initializeUserSession();
    } catch (e, stackTrace) {
      LoggerService.logError(
          '👤 Failed to initialize user session', e, stackTrace);
    }
  }

  Future<void> _loadContacts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<Contact> contacts = [];

      if (widget.userType == 'mother') {
        contacts = await ApiService.getMotherContacts();
      } else {
        contacts = await ApiService.getBabysitterContacts();
      }

      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      LoggerService.logError('📋 Failed to load contacts', e, stackTrace);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          if (SocketService.instance.isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Online',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading contacts',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContacts,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_contacts.isEmpty) {
      return Center(
        child: Text(
          'No contacts available',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContacts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContactCard(contact, index),
          );
        },
      ),
    );
  }

  Widget _buildContactCard(Contact contact, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  contactId: contact.id,
                  name: contact.name,
                  imageUrl: contact.imageUrl,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 25,
                  backgroundImage: contact.imageUrl != null
                      ? NetworkImage(contact.imageUrl!)
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  child: contact.imageUrl == null
                      ? Icon(
                          widget.userType == 'mother'
                              ? Icons.child_care
                              : Icons.person,
                          color: Colors.grey.shade600,
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Contact Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              const Color(0xFF1976D2), // Blue color for names
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.lastMessage ?? 'No messages yet',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Timestamp
                Text(
                  '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    SocketService.instance.disconnect();
    super.dispose();
  }
}
