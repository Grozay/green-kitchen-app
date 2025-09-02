import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatefulWidget {
  final int cartCount;
  final VoidCallback? onCartTap;
  final Widget body;

  const NavBar({
    Key? key,
    this.cartCount = 0,
    this.onCartTap,
    required this.body,
  }) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F5E7),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1CC29F),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  GoRouter.of(context).go('/profile');
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Color(0xFF1CC29F)),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Green User',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).go('/menumeal');
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Articles'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).go('/articles');
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Custom Meal'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).go('/custommeal');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Week Meal'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).go('/weekmeal');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Material(
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFF8F5E7),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black87),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(
                      child: Center(
                        child: const Text(
                          'GREEN KITCHEN',
                          style: TextStyle(
                            color: Color(0xFF1CC29F),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart, color: Colors.black87),
                          onPressed: () {
                            GoRouter.of(context).go('/cart');
                          },
                        ),
                        if (widget.cartCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1CC29F),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${widget.cartCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: widget.body),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4B0036),
        onPressed: () {},
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
