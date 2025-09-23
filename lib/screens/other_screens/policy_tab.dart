import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/theme/app_colors.dart';

class PolicyTab extends StatefulWidget {
  const PolicyTab({super.key});

  @override
  State<PolicyTab> createState() => _PolicyTabState();
}

class _PolicyTabState extends State<PolicyTab> {

  final List<Map<String, dynamic>> policies = [
    {
      'id': 'panel1',
      'title': '📋 Terms of Service',
      'icon': Icons.policy,
      'color': Colors.purple,
      'content': {
        'sections': [
          {
            'title': 'General Terms',
            'items': [
              'By using the service, you agree to comply with these terms',
              'We have the right to change terms without prior notice',
              'All disputes will be resolved according to Vietnamese law'
            ]
          },
          {
            'title': 'Rights and Obligations',
            'items': [
              'You have the right to use the service legally',
              'Do not use the service for illegal purposes',
              'Keep your account information secure'
            ]
          }
        ]
      }
    },
    {
      'id': 'panel2',
      'title': '🔒 Privacy Policy',
      'icon': Icons.security,
      'color': Colors.blue,
      'content': {
        'sections': [
          {
            'title': 'Information Collection',
            'items': [
              'Personal information: name, email, phone number, address',
              'Order information: dishes, time, delivery location',
              'Payment information: method, amount (card information not stored)'
            ]
          },
          {
            'title': 'Use of Information',
            'items': [
              'Process orders and delivery',
              'Send notifications and service updates',
              'Improve service quality and user experience'
            ]
          },
          {
            'title': 'Information Protection',
            'items': [
              'SSL/TLS encryption for all transactions',
              'Do not share information with third parties',
              'Comply with GDPR and Personal Data Protection laws'
            ]
          }
        ]
      }
    },
    {
      'id': 'panel3',
      'title': '🍽️ Order Policy',
      'icon': Icons.verified_user,
      'color': Colors.green,
      'content': {
        'sections': [
          {
            'title': 'Order Process',
            'items': [
              'Select dishes from menu and add to cart',
              'Confirm delivery address and payment information',
              'Receive order confirmation via email/SMS'
            ]
          },
          {
            'title': 'Order Cancellation Policy',
            'items': [
              'Can cancel order within 5 minutes after placing',
              'After 5 minutes, order will be processed and cannot be cancelled',
              'Contact hotline for support in special cases'
            ]
          },
          {
            'title': 'Delivery Time',
            'items': [
              'Delivery within 30-60 minutes depending on distance',
              'Notify 10 minutes before delivery arrival',
              'Compensation if delivery is more than 15 minutes late',
            ]
          }
        ]
      }
    },
    {
      'id': 'panel4',
      'title': '💰 Payment Policy',
      'icon': Icons.gavel,
      'color': Colors.orange,
      'content': {
        'sections': [
          {
            'title': 'Payment Methods',
            'items': [
              'Cash on delivery',
              'Bank transfer',
              'E-wallet (MoMo, ZaloPay, VNPay)',
              'Credit/debit cards (Visa, Mastercard)'
            ]
          },
          {
            'title': 'Payment Security',
            'items': [
              'SSL 256-bit encryption for all transactions',
              'Do not store credit card information',
              'Compliant with PCI DSS standards'
            ]
          },
          {
            'title': 'Refund and Compensation',
            'items': [
              '100% refund if food quality is not correct',
              'Compensation if delivery is late or wrong address',
              'Process refund within 3-5 business days'
            ]
          }
        ]
      }
    },
    {
      'id': 'panel5',
      'title': '🌟 Membership Policy',
      'icon': Icons.privacy_tip,
      'color': Colors.teal,
      'content': {
        'sections': [
          {
            'title': 'Reward Points',
            'items': [
              'Earn 1 point for every 10,000 VND spent',
              'Points are valid for 12 months',
              'Exchange points for discount coupons or free meals'
            ]
          },
          {
            'title': 'Membership Tiers',
            'items': [
              'ENERGY: Spend 0-2 million VND/6 months',
              'VITALITY: Spend 2-5 million VND/6 months',
              'RADIANCE: Spend over 5 million VND/6 months'
            ]
          },
          {
            'title': 'Special Offers',
            'items': [
              'Discounts based on membership tier',
              'Priority delivery for high-tier members',
              'Free appetizer for RADIANCE tier members'
            ]
          }
        ]
      }
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
            'Terms & Policy',
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
                      Colors.purple.shade600,
                      Colors.purple.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
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
                        Icons.policy,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terms of Service',
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
                      'Detailed information about rights and obligations when using the service',
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

              // Quick Policy Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Policy Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 4,
                      children: [
                        _buildPolicySummaryCard(
                          icon: Icons.check_circle,
                          title: 'Easy Ordering',
                          desc: 'Simple and fast process',
                          color: Colors.green,
                        ),
                        _buildPolicySummaryCard(
                          icon: Icons.security,
                          title: 'Absolute Security',
                          desc: 'Information encrypted with SSL/TLS',
                          color: Colors.blue,
                        ),
                        _buildPolicySummaryCard(
                          icon: Icons.verified_user,
                          title: 'On-time Delivery',
                          desc: '30-60 minute commitment',
                          color: Colors.orange,
                        ),
                        _buildPolicySummaryCard(
                          icon: Icons.policy,
                          title: '100% Refund',
                          desc: 'If not satisfied with quality',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Detailed Policies
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📖 Policy Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Policies accordion
                    ...policies.map((policy) => _buildPolicyAccordion(policy)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Important Notices
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.shade400,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.warning,
                            color: Colors.amber.shade600,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Important Notice',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '⚠️ Terms of Change',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'We have the right to update this policy at any time. Changes will take effect immediately when posted on the website.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.amber.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ℹ️ Contact Support',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'If you have questions about this policy, please contact us at: Email: policy@greenkitchen.com or Hotline: 1900-xxxx',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Policy Version and Last Updated
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    Text(
                      '📄 Policy Version: v1.1',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '📅 Last Updated: 23/09/2025',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '© 2025 Green Kitchen. All rights reserved.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySummaryCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyAccordion(Map<String, dynamic> policy) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.all(16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (policy['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              policy['icon'] as IconData,
              color: policy['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            policy['title'] as String,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (policy['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.expand_more,
          color: policy['color'] as Color,
          size: 20,
        ),
      ),
      onExpansionChanged: (expanded) {
        // Handle expansion state if needed
      },
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...(policy['content']['sections'] as List).map<Widget>((section) =>
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          section['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (section['items'] as List).map<Widget>((item) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ).toList(),
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ],
    );
  }
}
