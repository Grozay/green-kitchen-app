import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class tab_menu extends StatelessWidget {
  const tab_menu({
    super.key,
    required TabController tabController,
  }) : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44, // Set fixed height
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        dividerHeight: 0,
        isScrollable: false,
        tabAlignment: TabAlignment.fill,
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(height: 38, child: Text('LOW')),
          Tab(height: 38, child: Text('BALANCE')),
          Tab(height: 38, child: Text('HIGH')),
          Tab(height: 38, child: Text('VEG')),
        ],
      ),
    );
  }
}
