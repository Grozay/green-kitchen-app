import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FaqTab extends StatelessWidget {
  const FaqTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'q': 'How do I place an order?',
        'a': 'Browse the menu, add items to cart, and proceed to checkout.'
      },
      {
        'q': 'What payment methods are supported?',
        'a': 'Cash on delivery and common e-wallets/cards are supported.'
      },
      {
        'q': 'How can I track my order?',
        'a': 'You can view order status in the Order History section.'
      }
    ];

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          return true;
        }
        context.go('/profile');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/profile'),
          ),
          title: const Text('FAQs'),
        ),
        body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = faqs[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(
                item['q']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                Text(
                  item['a']!,
                  style: const TextStyle(color: Colors.black87),
                )
              ],
            ),
          );
        },
        ),
        backgroundColor: const Color(0xFFF5F5F5),
      ),
    );
  }
}


