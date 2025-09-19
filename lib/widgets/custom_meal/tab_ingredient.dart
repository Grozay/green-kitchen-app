import 'package:flutter/material.dart';

class tab_ingredient extends StatelessWidget {
  const tab_ingredient({
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
          color: Color(0xFF7DD3C0),
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
          labelColor: Color(0xFF4B0036),
          unselectedLabelColor: Colors.white,
          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          dividerColor: Colors.transparent,
          dividerHeight: 0,
          tabs: const [
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('PROTEIN'))),
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('CARBS'))),
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('SIDE'))),
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('SAUCE'))),
          ],
        ),
      ),
    );
  }
}