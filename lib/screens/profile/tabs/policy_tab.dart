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
      'title': '📋 Điều khoản sử dụng',
      'icon': Icons.policy,
      'color': Colors.purple,
      'content': {
        'sections': [
          {
            'title': 'Điều khoản chung',
            'items': [
              'Bằng việc sử dụng dịch vụ, bạn đồng ý tuân thủ các điều khoản này',
              'Chúng tôi có quyền thay đổi điều khoản mà không cần báo trước',
              'Mọi tranh chấp sẽ được giải quyết theo luật pháp Việt Nam'
            ]
          },
          {
            'title': 'Quyền và nghĩa vụ',
            'items': [
              'Bạn có quyền sử dụng dịch vụ một cách hợp pháp',
              'Không được sử dụng dịch vụ cho mục đích bất hợp pháp',
              'Bảo mật thông tin tài khoản của mình'
            ]
          }
        ]
      }
    },
    {
      'id': 'panel2',
      'title': '🔒 Chính sách bảo mật',
      'icon': Icons.security,
      'color': Colors.blue,
      'content': {
        'sections': [
          {
            'title': 'Thu thập thông tin',
            'items': [
              'Thông tin cá nhân: tên, email, số điện thoại, địa chỉ',
              'Thông tin đơn hàng: món ăn, thời gian, địa điểm giao hàng',
              'Thông tin thanh toán: phương thức, số tiền (không lưu thông tin thẻ)'
            ]
          },
          {
            'title': 'Sử dụng thông tin',
            'items': [
              'Xử lý đơn hàng và giao hàng',
              'Gửi thông báo và cập nhật dịch vụ',
              'Cải thiện chất lượng dịch vụ và trải nghiệm người dùng'
            ]
          },
          {
            'title': 'Bảo vệ thông tin',
            'items': [
              'Mã hóa SSL/TLS cho mọi giao dịch',
              'Không chia sẻ thông tin với bên thứ ba',
              'Tuân thủ quy định GDPR và Luật Bảo vệ dữ liệu cá nhân'
            ]
          }
        ]
      }
    },
    {
      'id': 'panel3',
      'title': '🍽️ Chính sách đặt hàng',
      'icon': Icons.verified_user,
      'color': Colors.green,
      'content': {
        'sections': [
          {
            'title': 'Quy trình đặt hàng',
            'items': [
              'Chọn món ăn từ menu và thêm vào giỏ hàng',
              'Xác nhận địa chỉ giao hàng và thông tin thanh toán',
              'Nhận xác nhận đơn hàng qua email/SMS'
            ]
          },
          {
            'title': 'Chính sách hủy đơn',
            'items': [
              'Có thể hủy đơn hàng trong vòng 5 phút sau khi đặt',
              'Sau 5 phút, đơn hàng sẽ được xử lý và không thể hủy',
              'Liên hệ hotline để được hỗ trợ trong trường hợp đặc biệt'
            ]
          },
          {
            'title': 'Thời gian giao hàng',
            'items': [
              'Giao hàng trong vòng 30-60 phút tùy thuộc khoảng cách',
              'Thông báo trước 10 phút khi đến giao hàng',
              'Bồi thường nếu giao hàng trễ quá 15 phút so với cam kết'
            ]
          }
        ]
      }
    },
    {
      'id': 'panel4',
      'title': '💰 Chính sách thanh toán',
      'icon': Icons.gavel,
      'color': Colors.orange,
      'content': {
        'sections': [
          {
            'title': 'Phương thức thanh toán',
            'items': [
              'Tiền mặt khi nhận hàng',
              'Chuyển khoản ngân hàng',
              'Ví điện tử (MoMo, ZaloPay, VNPay)',
              'Thẻ tín dụng/ghi nợ (Visa, Mastercard)'
            ]
          },
          {
            'title': 'Bảo mật thanh toán',
            'items': [
              'Mã hóa SSL 256-bit cho mọi giao dịch',
              'Không lưu trữ thông tin thẻ tín dụng',
              'Tuân thủ tiêu chuẩn PCI DSS'
            ]
          },
          {
            'title': 'Hoàn tiền và bồi thường',
            'items': [
              'Hoàn tiền 100% nếu món ăn không đúng chất lượng',
              'Bồi thường nếu giao hàng trễ hoặc sai địa chỉ',
              'Xử lý hoàn tiền trong vòng 3-5 ngày làm việc'
            ]
          }
        ]
      }
    },
    {
      'id': 'panel5',
      'title': '🌟 Chính sách thành viên',
      'icon': Icons.privacy_tip,
      'color': Colors.teal,
      'content': {
        'sections': [
          {
            'title': 'Tích điểm thưởng',
            'items': [
              'Tích 1 điểm cho mỗi 10,000 VNĐ chi tiêu',
              'Điểm có hiệu lực trong 12 tháng',
              'Đổi điểm lấy coupon giảm giá hoặc món ăn miễn phí'
            ]
          },
          {
            'title': 'Hạng thành viên',
            'items': [
              'ENERGY: Chi tiêu 0-2 triệu VNĐ/6 tháng',
              'VITALITY: Chi tiêu 2-5 triệu VNĐ/6 tháng',
              'RADIANCE: Chi tiêu trên 5 triệu VNĐ/6 tháng'
            ]
          },
          {
            'title': 'Ưu đãi đặc biệt',
            'items': [
              'Giảm giá theo hạng thành viên',
              'Ưu tiên giao hàng cho hạng cao',
              'Tặng món khai vị miễn phí cho hạng RADIANCE'
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
        context.go('/profile');
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
            onPressed: () => context.go('/profile'),
          ),
          title: Text(
            'Chính sách sử dụng',
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
                      'Chính Sách Sử Dụng',
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
                      'Thông tin chi tiết về quyền lợi và nghĩa vụ khi sử dụng dịch vụ',
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
                      '📋 Tóm tắt chính sách',
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
                          title: 'Đặt hàng dễ dàng',
                          desc: 'Quy trình đơn giản, nhanh chóng',
                          color: Colors.green,
                        ),
                        _buildPolicySummaryCard(
                          icon: Icons.security,
                          title: 'Bảo mật tuyệt đối',
                          desc: 'Thông tin được mã hóa SSL/TLS',
                          color: Colors.blue,
                        ),
                        _buildPolicySummaryCard(
                          icon: Icons.verified_user,
                          title: 'Giao hàng đúng giờ',
                          desc: 'Cam kết 30-60 phút',
                          color: Colors.orange,
                        ),
                        _buildPolicySummaryCard(
                          icon: Icons.policy,
                          title: 'Hoàn tiền 100%',
                          desc: 'Nếu không hài lòng về chất lượng',
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
                      '📖 Chi tiết chính sách',
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
                          'Lưu ý quan trọng',
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
                                  '⚠️ Điều khoản thay đổi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Chúng tôi có quyền cập nhật chính sách này bất cứ lúc nào. Những thay đổi sẽ có hiệu lực ngay khi được đăng tải trên website.',
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
                                  'ℹ️ Liên hệ hỗ trợ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Nếu bạn có thắc mắc về chính sách này, vui lòng liên hệ với chúng tôi qua: Email: policy@greenkitchen.com hoặc Hotline: 1900-xxxx',
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
                      '📄 Phiên bản chính sách: v2.1',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '📅 Cập nhật lần cuối: 15/12/2024',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '© 2024 Green Kitchen. Tất cả quyền được bảo lưu.',
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
    );
  }
}
