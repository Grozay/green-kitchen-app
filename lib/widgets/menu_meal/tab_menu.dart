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
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
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
          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          dividerColor: Colors.transparent,
          dividerHeight: 0,
          tabs: [
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text('LOW'))),
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 1), child: Text('BALANCE'))),
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text('HIGH'))),
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text('VEG'))),
          ],
        ),
      ),
    );
  }
}
