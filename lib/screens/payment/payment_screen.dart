import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = 'cash';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF4B0036)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: TextStyle(
            color: Color(0xFF4B0036),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B0036),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOrderItem('Pizza Calzone European (x2)', '\$96'),
                    _buildOrderItem('Pizza Calzone European (x1)', '\$32'),
                    Divider(height: 32, color: Colors.grey[300]),
                    _buildOrderItem('Subtotal', '\$128', isSubtotal: true),
                    _buildOrderItem('Delivery Fee', '\$5'),
                    _buildOrderItem('Tax', '\$8'),
                    Divider(height: 32, color: Colors.grey[300]),
                    _buildOrderItem('Total', '\$141', isTotal: true),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Delivery Address
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B0036),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Change',
                            style: TextStyle(
                              color: Color(0xFF1CC29F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2118 Thornridge Cir, Syracuse\nNew York, NY 13208',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Payment Method
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B0036),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment options
                    _buildPaymentOption(
                      'cash',
                      'Thanh toán khi nhận hàng',
                      Icons.money,
                    ),
                    _buildPaymentOption(
                      'paypal',
                      'PayPal',
                      Icons.payment,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1CC29F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    _processPayment();
                  },
                  child: Text(
                    selectedPaymentMethod == 'cash' 
                        ? 'Đặt hàng - \$141 (COD)'
                        : 'Thanh toán PayPal - \$141',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(String title, String price, {bool isSubtotal = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : (isSubtotal ? FontWeight.w600 : FontWeight.normal),
              color: isTotal ? Color(0xFF4B0036) : Colors.black87,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : (isSubtotal ? FontWeight.w600 : FontWeight.normal),
              color: isTotal ? Color(0xFF4B0036) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPaymentMethod == value ? Color(0xFF1CC29F) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedPaymentMethod == value ? Color(0xFF1CC29F).withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selectedPaymentMethod == value ? Color(0xFF1CC29F) : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selectedPaymentMethod == value ? Color(0xFF1CC29F) : Colors.black87,
              ),
            ),
            Spacer(),
            Radio<String>(
              value: value,
              groupValue: selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPaymentMethod = newValue!;
                });
              },
              activeColor: Color(0xFF1CC29F),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    // Show different processing message based on payment method
    String processingMessage = selectedPaymentMethod == 'cash' 
        ? 'Đang xử lý đơn hàng...'
        : 'Đang xử lý thanh toán PayPal...';
        
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1CC29F)),
                ),
                const SizedBox(height: 16),
                Text(
                  processingMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulate payment processing
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    String successMessage = selectedPaymentMethod == 'cash'
        ? 'Đơn hàng đã được đặt thành công!\nBạn sẽ thanh toán khi nhận hàng.'
        : 'Thanh toán thành công!\nĐơn hàng của bạn đã được xác nhận.';
        
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFF1CC29F),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  selectedPaymentMethod == 'cash' ? 'Đặt hàng thành công!' : 'Thanh toán thành công!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B0036),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  successMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1CC29F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to previous screen
                    },
                    child: Text(
                      'Tiếp tục',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
