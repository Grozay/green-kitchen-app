import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'account_info_screen.dart';
import 'membership_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    
    // Refresh customer details when entering profile screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshCustomerDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Simple TabBar in body
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.primary.withValues(alpha: 0.7),
                tabs: const [
                  Tab(text: 'Account', icon: Icon(Icons.person)),
                  Tab(text: 'Membership', icon: Icon(Icons.card_membership)),
                  Tab(text: 'Orders', icon: Icon(Icons.history)),
                ],
              ),
            ),
            // Tab content
            const Expanded(
              child: TabBarView(
                children: [
                  AccountInfoScreen(),
                  MembershipScreen(),
                  OrderHistoryScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
