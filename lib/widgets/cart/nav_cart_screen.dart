import 'package:flutter/material.dart';
import 'package:green_kitchen_app/theme/app_colors.dart';

class NavCartScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onCartTap;

  const NavCartScreen({
    Key? key,
    required this.title,
    required this.body,
    this.onCartTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        centerTitle: false,
      ),
      body: SafeArea(child: body),
    );
  }
}