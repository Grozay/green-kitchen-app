import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/theme/app_colors.dart';

class FaqTab extends StatefulWidget {
  const FaqTab({super.key});

  @override
  State<FaqTab> createState() => _FaqTabState();
}

class _FaqTabState extends State<FaqTab> {
  String? _expandedPanelId;

  final List<Map<String, dynamic>> faqs = [
    {
      'id': 'panel1',
      'title': '🛒 Order & Payment',
      'icon': Icons.shopping_cart,
      'color': AppColors.accent,
      'questions': [
        {
          'q': 'How to place an order?',
          'a': 'You can order through our website, mobile app or call our hotline directly. Simply select items from the menu, add to cart and proceed to checkout.'
        },
        {
          'q': 'What is the delivery time?',
          'a': 'Delivery time is 30-60 minutes depending on distance and traffic conditions. We will notify you 10 minutes before arrival.'
        },
        {
          'q': 'What payment methods are available?',
          'a': 'We accept cash, credit cards, e-wallets (MoMo, ZaloPay, VNPay) and bank transfers. All transactions are encrypted with SSL 256-bit.'
        },
        {
          'q': 'Can I cancel my order?',
          'a': 'You can cancel your order within 5 minutes after placing it. After this time, the order will be processed and cannot be cancelled. Please contact our hotline for support.'
        }
      ]
    },
    {
      'id': 'panel2',
      'title': '🍽️ Food & Quality',
      'icon': Icons.restaurant,
      'color': AppColors.secondary,
      'questions': [
        {
          'q': 'Is the food hot when delivered?',
          'a': 'We use specialized thermal bags to ensure food maintains optimal temperature throughout delivery.'
        },
        {
          'q': 'Can I modify food ingredients?',
          'a': 'You can request adjustments for some dishes when ordering. Please add detailed notes in the "Special Notes" section.'
        },
        {
          'q': 'Is food safety guaranteed?',
          'a': 'All ingredients are strictly inspected, processed in HACCP-standard environment and comply with food safety regulations.'
        }
      ]
    },
    {
      'id': 'panel3',
      'title': '👤 Account & Membership',
      'icon': Icons.account_circle,
      'color': Colors.purple,
      'questions': [
        {
          'q': 'How to become a member?',
          'a': 'Simply place one order and you will automatically become a member with access to exclusive benefits from our loyalty program.'
        },
        {
          'q': 'Forgot password, how to recover?',
          'a': 'Click "Forgot Password" on the login page, enter your registered email. We will send a password reset link within 5 minutes.'
        },
        {
          'q': 'What are member benefits?',
          'a': 'Members earn reward points, tier-based discounts, priority delivery and many other special benefits based on membership level.'
        }
      ]
    },
    {
      'id': 'panel4',
      'title': '📞 Support & Feedback',
      'icon': Icons.support,
      'color': Colors.blue,
      'questions': [
        {
          'q': 'How to contact support?',
          'a': 'You can contact us via hotline 1900-xxxx, email support@greenkitchen.com or 24/7 online chat on website and app.'
        },
        {
          'q': 'Support response time?',
          'a': 'Support team operates 24/7. We commit to respond within 5 minutes for online chat and 24 hours for email.'
        },
        {
          'q': 'Can I provide service quality feedback?',
          'a': 'We highly value all customer feedback. You can provide feedback through the app, website or directly to delivery staff.'
        }
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          return true;
        }
        context.go('/more');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.go('/more'),
          ),
          title: Text(
            'FAQ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find answers to common questions',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // FAQ Categories
              ...faqs.map((category) => _buildFaqCategory(category)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCategory(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (category['color'] as Color).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: (category['color'] as Color).withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  category['title'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // FAQ Items
          ...category['questions'].map<Widget>((faq) => _buildFaqItem(faq, category['color'] as Color)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, String> faq, Color color) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      title: Text(
        faq['q']!,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.expand_more,
          color: color,
          size: 20,
        ),
      ),
      onExpansionChanged: (expanded) {
        setState(() {
          _expandedPanelId = expanded ? faq['q'] : null;
        });
      },
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            faq['a']!,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}


