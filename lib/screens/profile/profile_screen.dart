import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/app_layout.dart';
import './account_info_screen.dart';

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
    return AppLayout(
      title: 'PROFILE',
      currentIndex: 4, // Assuming profile is index 4 in bottom navigation
      body: const AccountInfoScreen(),
    );
  }
}
