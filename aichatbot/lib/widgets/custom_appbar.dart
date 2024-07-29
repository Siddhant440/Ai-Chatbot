import 'package:flutter/material.dart';
import '../utils/style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final Icon iconButton;
  final String? logo;
  final VoidCallback onPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.iconButton,
    this.logo,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (logo != null)
            Padding(
              padding: const EdgeInsets.only(right: 55),
              child: Row(
                children: [
                  Image.asset(
                    logo!,
                    height: 30,
                    width: 50,
                  ),
                  const SizedBox(width: 5),
                  Text("Powered",style: TextStyle(fontSize: 7,color: uiText,fontWeight: FontWeight.bold))
                ],
              ),
            ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: iconButton,
            onPressed: onPressed,
            color: userChat,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}