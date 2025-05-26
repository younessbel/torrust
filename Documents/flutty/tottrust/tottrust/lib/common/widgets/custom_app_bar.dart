import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final VoidCallback? onBack;

  const CustomAppBar({this.showBack = false, this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFC3DFFF),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(70),
              bottomRight: Radius.circular(70),
            ),
          ),
        ),
        if (showBack)
          Positioned(
            left: 8,
            top: 30,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 30, color: Colors.blue),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Image.asset(
              'assets/images/bebe.png',
              width: 60,
              height: 60,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
