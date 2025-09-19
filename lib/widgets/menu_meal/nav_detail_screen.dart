import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:green_kitchen_app/provider/cart_provider.dart';
import 'package:green_kitchen_app/theme/app_colors.dart';

class NavDetailScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onCartTap;

  const NavDetailScreen({
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
        // centerTitle: false,
        // actions: [
        //   Consumer<CartProvider>(
        //     builder: (context, cartProvider, child) {
        //       return Stack(
        //         children: [
        //           IconButton(
        //             icon: const Icon(
        //               Icons.shopping_cart,
        //               color: AppColors.textPrimary,
        //             ),
        //             onPressed: onCartTap ?? () {
        //               GoRouter.of(context).go('/cart');
        //             },
        //           ),
        //           if (cartProvider.cartItemCount > 0)
        //             Positioned(
        //               right: 6,
        //               top: 6,
        //               child: Container(
        //                 padding: const EdgeInsets.all(4),
        //                 decoration: const BoxDecoration(
        //                   color: AppColors.secondary,
        //                   shape: BoxShape.circle,
        //                 ),
        //                 constraints: const BoxConstraints(
        //                   minWidth: 10,
        //                   minHeight: 10,
        //                 ),
        //                 child: Text(
        //                   '${cartProvider.cartItemCount}',
        //                   style: const TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 12,
        //                     fontWeight: FontWeight.bold,
        //                   ),
        //                   textAlign: TextAlign.center,
        //                 ),
        //               ),
        //             ),
        //         ],
        //       );
        //     },
        //   ),
        //   const SizedBox(width: 8),
        // ],
      ),
      body: SafeArea(child: body),
    );
  }
}