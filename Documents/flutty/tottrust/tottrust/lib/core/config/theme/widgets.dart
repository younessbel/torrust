// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class upcomingBook extends StatelessWidget {
  String name;
  String description;
  String date;
  String time;
  String img; // Replace with your image path
  upcomingBook({
    Key? key,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.img,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Reduced width to 200
      padding: EdgeInsets.all(10), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // More rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25, // Reduced radius
                child: Icon(Icons.person),
              ),
              SizedBox(width: 5), // Reduced spacing
              Expanded(
                // Use Expanded to prevent overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Color.fromRGBO(55, 95, 155, 1),
                        fontSize: 12, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Prevent overflow
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10, // Reduced font size
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8), // Reduced spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the row
            children: [
              Icon(Icons.calendar_today,
                  size: 14,
                  color: const Color.fromARGB(
                      255, 220, 91, 91)), // Reduced icon size
              SizedBox(width: 3), // Reduced spacing
              Text(
                date,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 5),
              Icon(Icons.access_time,
                  size: 14, color: const Color.fromARGB(255, 220, 40, 40)),
              SizedBox(width: 3),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EarningsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Adjust width as needed
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // More rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Earnings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800], // Darker blue
                ),
              ),
              Row(
                children: [
                  Text(
                    'Amount:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          const Color.fromARGB(255, 90, 88, 252), // Darker blue
                    ),
                  ),
                  Text(
                    ' 300\$',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(
                          255, 21, 192, 158), // Darker blue
                    ),
                  )
                ],
              ),
              Text(
                'Time Period: "This Week"',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Image.asset(
            'assets/images/background.jpg', // Replace with your image path
            width: 40,
            height: 40,
          ),
        ],
      ),
    );
  }
}
