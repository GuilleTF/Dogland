// widgets/home_app_bar.dart

import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback onLogout;
  final bool showBackButton;

  HomeAppBar({
    required this.title,
    required this.onLogout,
    this.onBackPressed,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.purple,
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed,
            )
          : null,
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.white),
          onPressed: onLogout,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
