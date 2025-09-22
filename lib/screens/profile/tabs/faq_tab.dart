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
      'title': '🛒 Đặt hàng & Thanh toán',
      'icon': Icons.shopping_cart,
      'color': AppColors.accent,
      'questions': [
        {
          'q': 'Làm thế nào để đặt hàng?',
          'a': 'Bạn có thể đặt hàng qua website, ứng dụng mobile hoặc gọi điện trực tiếp đến hotline của chúng tôi. Chỉ cần chọn món ăn từ menu, thêm vào giỏ hàng và tiến hành thanh toán.'
        },
        {
          'q': 'Thời gian giao hàng là bao lâu?',
          'a': 'Thời gian giao hàng từ 30-60 phút tùy thuộc vào khoảng cách và tình trạng giao thông. Chúng tôi sẽ thông báo trước 10 phút khi đến giao hàng.'
        },
        {
          'q': 'Có thể thanh toán bằng cách nào?',
          'a': 'Chúng tôi chấp nhận thanh toán tiền mặt, thẻ tín dụng, ví điện tử (MoMo, ZaloPay, VNPay) và chuyển khoản ngân hàng. Mọi giao dịch đều được mã hóa SSL 256-bit.'
        },
        {
          'q': 'Có thể hủy đơn hàng không?',
          'a': 'Bạn có thể hủy đơn hàng trong vòng 5 phút sau khi đặt. Sau thời gian này, đơn hàng sẽ được xử lý và không thể hủy. Vui lòng liên hệ hotline để được hỗ trợ.'
        }
      ]
    },
    {
      'id': 'panel2',
      'title': '🍽️ Món ăn & Chất lượng',
      'icon': Icons.restaurant,
      'color': AppColors.secondary,
      'questions': [
        {
          'q': 'Món ăn có nóng khi giao đến không?',
          'a': 'Chúng tôi sử dụng túi giữ nhiệt chuyên dụng để đảm bảo món ăn giữ được độ nóng tối ưu trong suốt quá trình giao hàng.'
        },
        {
          'q': 'Có thể thay đổi thành phần món ăn không?',
          'a': 'Bạn có thể yêu cầu điều chỉnh một số món ăn khi đặt hàng. Vui lòng ghi chú chi tiết trong phần "Ghi chú đặc biệt" khi đặt hàng.'
        },
        {
          'q': 'Món ăn có đảm bảo vệ sinh an toàn thực phẩm?',
          'a': 'Tất cả nguyên liệu đều được kiểm tra nghiêm ngặt, chế biến trong môi trường đạt chuẩn HACCP và tuân thủ quy định ATTP của Bộ Y tế.'
        }
      ]
    },
    {
      'id': 'panel3',
      'title': '👤 Tài khoản & Thành viên',
      'icon': Icons.account_circle,
      'color': Colors.purple,
      'questions': [
        {
          'q': 'Làm sao để trở thành thành viên?',
          'a': 'Chỉ cần đặt hàng một lần, bạn sẽ tự động trở thành thành viên và nhận được nhiều ưu đãi hấp dẫn từ chương trình khách hàng thân thiết.'
        },
        {
          'q': 'Quên mật khẩu, làm thế nào để lấy lại?',
          'a': 'Click vào "Quên mật khẩu" trên trang đăng nhập, nhập email đã đăng ký. Chúng tôi sẽ gửi link đặt lại mật khẩu trong vòng 5 phút.'
        },
        {
          'q': 'Ưu đãi cho thành viên là gì?',
          'a': 'Thành viên được tích điểm thưởng, giảm giá theo hạng, ưu tiên giao hàng và nhiều ưu đãi đặc biệt khác tùy theo cấp độ thành viên.'
        }
      ]
    },
    {
      'id': 'panel4',
      'title': '📞 Hỗ trợ & Phản hồi',
      'icon': Icons.support,
      'color': Colors.blue,
      'questions': [
        {
          'q': 'Làm sao để liên hệ hỗ trợ?',
          'a': 'Bạn có thể liên hệ qua hotline 1900-xxxx, email support@greenkitchen.com hoặc chat trực tuyến 24/7 trên website và ứng dụng.'
        },
        {
          'q': 'Thời gian phản hồi hỗ trợ?',
          'a': 'Đội ngũ hỗ trợ hoạt động 24/7. Chúng tôi cam kết phản hồi trong vòng 5 phút cho chat trực tuyến và 24h cho email.'
        },
        {
          'q': 'Có thể phản hồi về chất lượng dịch vụ không?',
          'a': 'Chúng tôi rất trân trọng mọi phản hồi từ khách hàng. Bạn có thể gửi phản hồi qua ứng dụng, website hoặc trực tiếp cho nhân viên giao hàng.'
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
            'Câu hỏi thường gặp',
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
                      'Câu hỏi thường gặp',
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
                      'Tìm câu trả lời cho những thắc mắc phổ biến',
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


