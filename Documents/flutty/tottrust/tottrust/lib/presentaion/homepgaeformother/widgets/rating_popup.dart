import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RatingPopup extends StatefulWidget {
  final Map<String, dynamic> babysitter;
  final VoidCallback? onRatingSubmitted;

  const RatingPopup({
    Key? key,
    required this.babysitter,
    this.onRatingSubmitted,
  }) : super(key: key);

  @override
  State<RatingPopup> createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup>
    with TickerProviderStateMixin {
  int _currentRating = 0;
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late AnimationController _starAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _starScaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentRating = (widget.babysitter['avgRating'] ?? 0).round();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _starScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _starAnimationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_currentRating == 0) {
      _showSnackBar('Please select a rating', Colors.orange);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        _showSnackBar('Please login first', Colors.red);
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.8.102:4000/rate-babysitter'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'babysitterId': widget.babysitter['_id'],
          'stars': _currentRating,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Rating submitted successfully!', Colors.green);
        if (widget.onRatingSubmitted != null) {
          widget.onRatingSubmitted!();
        }
        Navigator.of(context).pop();
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(
            error['message'] ?? 'Failed to submit rating', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _onStarTap(int rating) {
    setState(() {
      _currentRating = rating;
    });
    _starAnimationController.forward().then((_) {
      _starAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Container(
                  width: screenWidth * 0.85,
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.75,
                    minHeight: 400,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(),
                            Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildProfileSection(),
                                    _buildRatingSection(),
                                  ],
                                ),
                              ),
                            ),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star_rate_rounded,
              color: Colors.amber,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rate Experience',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Share your feedback',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    String? profilePhoto = widget.babysitter['profilePhoto'];
    String imageUrl = profilePhoto != null
        ? "http://192.168.8.102:4000/$profilePhoto"
        : 'assets/images/girl1.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF667eea).withOpacity(0.2),
                            const Color(0xFF764ba2).withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: profilePhoto != null
                      ? NetworkImage(imageUrl)
                      : AssetImage(imageUrl) as ImageProvider,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            widget.babysitter['fullname'] ?? 'Unknown',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF667eea),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Current Rating
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < (widget.babysitter['avgRating'] ?? 0).round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber.shade600,
                    size: 14,
                  );
                }),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(widget.babysitter['avgRating'] ?? 0).toStringAsFixed(1)}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Age and Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoCard(
                icon: Icons.cake_rounded,
                text: '${widget.babysitter['age'] ?? 'N/A'} years',
                color: Colors.pink.shade300,
              ),
              const SizedBox(width: 8),
              _buildInfoCard(
                icon: Icons.location_on_rounded,
                text: widget.babysitter['location'] ?? 'Unknown',
                color: Colors.blue.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your feedback helps others make better choices',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Interactive Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              bool isSelected = index < _currentRating;
              return GestureDetector(
                onTap: () => _onStarTap(index + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                Colors.orange.shade400
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Rating Text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              key: ValueKey(_currentRating),
              _getRatingText(_currentRating),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _getRatingColor(_currentRating),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Submit',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor Experience';
      case 2:
        return 'Fair Experience';
      case 3:
        return 'Good Experience';
      case 4:
        return 'Very Good Experience';
      case 5:
        return 'Excellent Experience';
      default:
        return 'Tap stars to rate';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red.shade500;
      case 2:
        return Colors.orange.shade500;
      case 3:
        return Colors.amber.shade600;
      case 4:
        return Colors.lightGreen.shade500;
      case 5:
        return Colors.green.shade500;
      default:
        return Colors.grey.shade500;
    }
  }
}

// Helper function to show the rating popup
void showRatingPopup(BuildContext context, Map<String, dynamic> babysitter,
    {VoidCallback? onRatingSubmitted}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return RatingPopup(
        babysitter: babysitter,
        onRatingSubmitted: onRatingSubmitted,
      );
    },
  );
}
