import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_text_field.dart';
import 'store_selector.dart';

class DeliveryInfoStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onFormDataChanged;
  final VoidCallback onNext;

  const DeliveryInfoStep({
    super.key,
    required this.formData,
    required this.onFormDataChanged,
    required this.onNext,
  });

  @override
  State<DeliveryInfoStep> createState() => _DeliveryInfoStepState();
}

class _DeliveryInfoStepState extends State<DeliveryInfoStep> {
  final _formKey = GlobalKey<FormState>();

  // Contact Information
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  // Delivery Address
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _districtController;
  late final TextEditingController _wardController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _fullNameController = TextEditingController(text: widget.formData['fullName'] ?? '');
    _emailController = TextEditingController(text: widget.formData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.formData['phone'] ?? '');
    _addressController = TextEditingController(text: widget.formData['address'] ?? '');
    _cityController = TextEditingController(text: widget.formData['city'] ?? '');
    _districtController = TextEditingController(text: widget.formData['district'] ?? '');
    _wardController = TextEditingController(text: widget.formData['ward'] ?? '');
    _noteController = TextEditingController(text: widget.formData['note'] ?? '');

    // Pre-fill user information if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null && _fullNameController.text.isEmpty) {
        _fullNameController.text = authProvider.currentUser!.fullName ?? '';
        _emailController.text = authProvider.currentUser!.email;
        _phoneController.text = authProvider.currentUser!.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateFormData() {
    widget.onFormDataChanged('fullName', _fullNameController.text);
    widget.onFormDataChanged('email', _emailController.text);
    widget.onFormDataChanged('phone', _phoneController.text);
    widget.onFormDataChanged('address', _addressController.text);
    widget.onFormDataChanged('city', _cityController.text);
    widget.onFormDataChanged('district', _districtController.text);
    widget.onFormDataChanged('ward', _wardController.text);
    widget.onFormDataChanged('note', _noteController.text);
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      _updateFormData();
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Information Section
            _buildSectionHeader('Thông tin liên hệ'),
            const SizedBox(height: 16),
            _buildContactInformation(),

            const SizedBox(height: 24),

            // Store Selection Section
            _buildSectionHeader('Chọn cửa hàng giao hàng'),
            const SizedBox(height: 16),
            StoreSelector(
              selectedStore: widget.formData['selectedStore'],
              onStoreSelected: (store) {
                widget.onFormDataChanged('selectedStore', store);
              },
            ),

            const SizedBox(height: 24),

            // Delivery Address Section
            _buildSectionHeader('Địa chỉ giao hàng'),
            const SizedBox(height: 16),
            _buildDeliveryAddress(),

            const SizedBox(height: 32),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _handleNext,
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildContactInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _fullNameController,
            labelText: 'Họ và tên',
            hintText: 'Nhập họ và tên',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Nhập địa chỉ email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            labelText: 'Số điện thoại',
            hintText: 'Nhập số điện thoại',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              if (value.length < 10) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _addressController,
            labelText: 'Địa chỉ',
            hintText: 'Nhập địa chỉ chi tiết',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập địa chỉ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _wardController,
                  labelText: 'Phường/Xã',
                  hintText: 'Phường/Xã',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập phường/xã';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _districtController,
                  labelText: 'Quận/Huyện',
                  hintText: 'Quận/Huyện',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập quận/huyện';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _cityController,
            labelText: 'Tỉnh/Thành phố',
            hintText: 'Tỉnh/Thành phố',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tỉnh/thành phố';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _noteController,
            labelText: 'Ghi chú (tùy chọn)',
            hintText: 'Ví dụ: Giao hàng giờ hành chính',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}