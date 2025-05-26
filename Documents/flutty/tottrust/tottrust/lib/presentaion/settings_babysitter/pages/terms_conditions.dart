import 'package:flutter/material.dart';

class BabysitterTermsPage extends StatelessWidget {
  final List<String> terms = [
    "👩‍👧 1. Babysitters must always act with care and professionalism.",
    "🏡 2. Mothers must provide accurate home and child information.",
    "⏰ 3. Respect agreed hours — punctuality is important.",
    "🤝 4. Both sides must confirm bookings through the app.",
    "📱 5. Chat should be used only for app-related communication.",
    "🧼 6. Babysitters are responsible for basic child hygiene and safety.",
    "📷 7. No photos or videos of children without permission.",
    "💬 8. Report any suspicious activity immediately to support.",
    "🔒 9. All personal data is protected and not shared.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F0FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFE3F0FF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ListView.builder(
          itemCount: terms.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: Text(
                terms[index],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
