import 'package:flutter/material.dart';

class acc extends StatelessWidget {
  final String name;
  final String description;
  final String date;
  const acc(
      {super.key,
      required this.name,
      required this.description,
      required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 8.0, left: 5, bottom: 5), // Increased bottom padding
      child: Container(
        width: 400, // Adjust width as needed
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
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5), // Increased bottom padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.girl), // Replace with your image asset
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(55, 95, 155, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(138, 138, 138, 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1),
            Text(
              description,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromRGBO(138, 138, 138, 1)),
            ),
            SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Accept',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(55, 95, 155, 1),
                    backgroundColor:
                        Color.fromRGBO(195, 233, 255, 1), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Decline',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(155, 55, 75, 1),
                    backgroundColor: Color.fromRGBO(239, 221, 222, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
}
