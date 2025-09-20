import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/theme/app_colors.dart';
import 'package:green_kitchen_app/services/feedback_service.dart';

class FeedbackTab extends StatefulWidget {
  const FeedbackTab({super.key});

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  bool _feedbackDialogOpen = false;
  bool _supportDialogOpen = false;

  // Feedback form
  final TextEditingController _feedbackTypeController = TextEditingController(text: 'GENERAL');
  final TextEditingController _feedbackRatingController = TextEditingController(text: '5');
  final TextEditingController _feedbackTitleController = TextEditingController();
  final TextEditingController _feedbackDescriptionController = TextEditingController();
  final TextEditingController _feedbackEmailController = TextEditingController();

  // Support form
  final TextEditingController _supportIssueTypeController = TextEditingController(text: 'TECHNICAL');
  final TextEditingController _supportPriorityController = TextEditingController(text: 'MEDIUM');
  final TextEditingController _supportSubjectController = TextEditingController();
  final TextEditingController _supportDescriptionController = TextEditingController();
  final TextEditingController _supportContactMethodController = TextEditingController(text: 'EMAIL');

  @override
  void dispose() {
    _feedbackTypeController.dispose();
    _feedbackRatingController.dispose();
    _feedbackTitleController.dispose();
    _feedbackDescriptionController.dispose();
    _feedbackEmailController.dispose();

    _supportIssueTypeController.dispose();
    _supportPriorityController.dispose();
    _supportSubjectController.dispose();
    _supportDescriptionController.dispose();
    _supportContactMethodController.dispose();

    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_feedbackTitleController.text.isEmpty || _feedbackDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: AppColors.accent,
        ),
      );
      return;
    }

    try {
      final success = await FeedbackService.submitFeedback(
        type: _feedbackTypeController.text,
        rating: _feedbackRatingController.text.isEmpty ? null : int.parse(_feedbackRatingController.text),
        title: _feedbackTitleController.text,
        description: _feedbackDescriptionController.text,
        contactEmail: _feedbackEmailController.text.isEmpty ? null : _feedbackEmailController.text,
        fromEmail: _feedbackEmailController.text.isEmpty ? null : _feedbackEmailController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cảm ơn phản hồi của bạn! Chúng tôi sẽ xử lý trong thời gian sớm nhất.'),
            backgroundColor: AppColors.secondary,
          ),
        );

        setState(() {
          _feedbackDialogOpen = false;
        });

        _feedbackTitleController.clear();
        _feedbackDescriptionController.clear();
        _feedbackEmailController.clear();
        _feedbackTypeController.text = 'GENERAL';
        _feedbackRatingController.text = '5';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi gửi phản hồi. Vui lòng thử lại.'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  Future<void> _submitSupport() async {
    if (_supportSubjectController.text.isEmpty || _supportDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: AppColors.accent,
        ),
      );
      return;
    }

    try {
      final success = await FeedbackService.submitSupportRequest(
        issueType: _supportIssueTypeController.text,
        priority: _supportPriorityController.text,
        subject: _supportSubjectController.text,
        description: _supportDescriptionController.text,
        contactMethod: _supportContactMethodController.text,
        contactValue: _supportContactMethodController.text == 'EMAIL' ? (_feedbackEmailController.text.isEmpty ? 'user@example.com' : _feedbackEmailController.text) : 'N/A',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yêu cầu hỗ trợ đã được gửi! Chúng tôi sẽ liên hệ với bạn trong thời gian sớm nhất.'),
            backgroundColor: AppColors.secondary,
          ),
        );

        setState(() {
          _supportDialogOpen = false;
        });

        _supportSubjectController.clear();
        _supportDescriptionController.clear();
        _supportIssueTypeController.text = 'TECHNICAL';
        _supportPriorityController.text = 'MEDIUM';
        _supportContactMethodController.text = 'EMAIL';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi gửi yêu cầu hỗ trợ. Vui lòng thử lại.'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

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
            'Hỗ trợ & Phản hồi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
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
                          AppColors.secondary,
                          AppColors.secondary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
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
                            Icons.support_agent,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hỗ trợ & Phản hồi',
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
                          'Chúng tôi luôn sẵn sàng hỗ trợ bạn 24/7',
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

                  // Quick Action Cards
                  GridView.count(
                    crossAxisCount: 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3,
                    children: [
                      _buildQuickActionCard(
                        icon: Icons.support,
                        title: 'Yêu cầu hỗ trợ',
                        subtitle: 'Gặp vấn đề? Chúng tôi sẽ giúp bạn giải quyết nhanh chóng',
                        color: AppColors.primary,
                        onTap: () => setState(() => _supportDialogOpen = true),
                      ),
                      _buildQuickActionCard(
                        icon: Icons.feedback,
                        title: 'Gửi phản hồi',
                        subtitle: 'Chia sẻ ý kiến để chúng tôi cải thiện dịch vụ tốt hơn',
                        color: AppColors.accent,
                        onTap: () => setState(() => _feedbackDialogOpen = true),
                      ),
                      _buildQuickActionCard(
                        icon: Icons.chat,
                        title: 'Chat trực tuyến',
                        subtitle: 'Trò chuyện trực tiếp với nhân viên hỗ trợ',
                        color: Colors.green,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tính năng chat sẽ sớm có mặt!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Contact Information
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
                          '📞 Thông tin liên hệ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildContactInfo(
                                icon: Icons.phone,
                                title: 'Hotline',
                                value: '1900-xxxx',
                                subtitle: '8:00 - 22:00 (T2-CN)',
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildContactInfo(
                                icon: Icons.email,
                                title: 'Email',
                                value: 'support@greenkitchen.com',
                                subtitle: 'Phản hồi trong 24h',
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildContactInfo(
                                icon: Icons.location_on,
                                title: 'Văn phòng',
                                value: 'TP. Hồ Chí Minh',
                                subtitle: '123 Đường ABC, Quận 1',
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildContactInfo(
                                icon: Icons.chat_bubble,
                                title: 'Live Chat',
                                value: 'Trực tuyến 24/7',
                                subtitle: 'Hỗ trợ tức thì',
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // FAQ Section
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
                          '❓ Câu hỏi thường gặp',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildFaqItem(
                          question: 'Làm thế nào để đặt hàng?',
                          answer: 'Bạn có thể đặt hàng qua website, ứng dụng mobile hoặc gọi điện trực tiếp đến hotline của chúng tôi.',
                        ),
                        const Divider(height: 32),
                        _buildFaqItem(
                          question: 'Thời gian giao hàng là bao lâu?',
                          answer: 'Thời gian giao hàng từ 30-60 phút tùy thuộc vào khoảng cách và tình trạng giao thông.',
                        ),
                        const Divider(height: 32),
                        _buildFaqItem(
                          question: 'Có thể thanh toán bằng cách nào?',
                          answer: 'Chúng tôi chấp nhận thanh toán tiền mặt, thẻ tín dụng, ví điện tử và chuyển khoản ngân hàng.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Feedback Dialog
            if (_feedbackDialogOpen) _buildFeedbackDialog(),

            // Support Dialog
            if (_supportDialogOpen) _buildSupportDialog(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          answer,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackDialog() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Gửi phản hồi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => setState(() => _feedbackDialogOpen = false),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Dialog Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _feedbackTypeController.text,
                        decoration: InputDecoration(
                          labelText: 'Loại phản hồi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'GENERAL', child: Text('Phản hồi chung')),
                          DropdownMenuItem(value: 'FOOD_QUALITY', child: Text('Chất lượng món ăn')),
                          DropdownMenuItem(value: 'SERVICE', child: Text('Dịch vụ')),
                          DropdownMenuItem(value: 'DELIVERY', child: Text('Giao hàng')),
                          DropdownMenuItem(value: 'WEBSITE', child: Text('Website/Ứng dụng')),
                        ],
                        onChanged: (value) => setState(() => _feedbackTypeController.text = value!),
                      ),
                      const SizedBox(height: 16),

                    Text(
                        'Đánh giá tổng thể',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: () => setState(() => _feedbackRatingController.text = '${index + 1}'),
                            icon: Icon(
                              index < int.parse(_feedbackRatingController.text)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _feedbackTitleController,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề phản hồi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _feedbackDescriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Mô tả chi tiết',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _feedbackEmailController,
                        decoration: InputDecoration(
                          labelText: 'Email liên hệ (tùy chọn)',
                          hintText: 'Để nhận phản hồi từ chúng tôi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dialog Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _feedbackDialogOpen = false),
                      child: Text(
                        'Hủy',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async => await _submitFeedback(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Gửi phản hồi'),
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

  Widget _buildSupportDialog() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.support,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                    Text(
                          'Yêu cầu hỗ trợ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => setState(() => _supportDialogOpen = false),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Dialog Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _supportIssueTypeController.text,
                              decoration: InputDecoration(
                                labelText: 'Loại vấn đề',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'TECHNICAL', child: Text('Vấn đề kỹ thuật')),
                                DropdownMenuItem(value: 'ORDER', child: Text('Vấn đề đặt hàng')),
                                DropdownMenuItem(value: 'PAYMENT', child: Text('Vấn đề thanh toán')),
                                DropdownMenuItem(value: 'DELIVERY', child: Text('Vấn đề giao hàng')),
                                DropdownMenuItem(value: 'ACCOUNT', child: Text('Vấn đề tài khoản')),
                              ],
                              onChanged: (value) => setState(() => _supportIssueTypeController.text = value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _supportPriorityController.text,
                              decoration: InputDecoration(
                                labelText: 'Mức độ ưu tiên',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'LOW', child: Text('Thấp')),
                                DropdownMenuItem(value: 'MEDIUM', child: Text('Trung bình')),
                                DropdownMenuItem(value: 'HIGH', child: Text('Cao')),
                                DropdownMenuItem(value: 'URGENT', child: Text('Khẩn cấp')),
                              ],
                              onChanged: (value) => setState(() => _supportPriorityController.text = value!),
                            ),
                          ),
                        ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                        controller: _supportSubjectController,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề yêu cầu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                        controller: _supportDescriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Mô tả chi tiết vấn đề',
                          hintText: 'Vui lòng mô tả chi tiết vấn đề bạn gặp phải...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
              ),
              const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _supportContactMethodController.text,
                        decoration: InputDecoration(
                          labelText: 'Phương thức liên hệ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'EMAIL', child: Text('Email')),
                          DropdownMenuItem(value: 'PHONE', child: Text('Điện thoại')),
                          DropdownMenuItem(value: 'CHAT', child: Text('Live Chat')),
                        ],
                        onChanged: (value) => setState(() => _supportContactMethodController.text = value!),
                      ),
            ],
          ),
        ),
        ),

              // Dialog Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _supportDialogOpen = false),
                      child: Text(
                        'Hủy',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async => await _submitSupport(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Gửi yêu cầu'),
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
}


