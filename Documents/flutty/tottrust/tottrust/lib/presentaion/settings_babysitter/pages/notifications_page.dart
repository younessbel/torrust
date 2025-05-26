import 'package:flutter/material.dart';

class NotificationsPage1 extends StatelessWidget {
  const NotificationsPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            NotificationTile(
              title: 'New Booking Request',
              subtitle: 'You have a new booking request from Amel Bel.',
              date: 'March 17, 2025',
            ),
            NotificationTile(
              title: 'Booking Confirmed',
              subtitle: 'Your booking with Wafaa Benia has been confirmed.',
              date: 'March 16, 2025',
            ),
            NotificationTile(
              title: 'Payment Received',
              subtitle: 'You have received a payment for your last booking.',
              date: 'March 15, 2025',
            ),
            // Add more NotificationTile widgets as needed
          ],
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;

  const NotificationTile({
    required this.title,
    required this.subtitle,
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO(173, 216, 230, 1), // Light blue background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: Text(
          date,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
