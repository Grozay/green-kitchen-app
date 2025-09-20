import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/chat_response.dart';

class ProductMessageBubble extends StatefulWidget {
  final ChatResponse message;
  final bool isMine;

  const ProductMessageBubble({
    Key? key,
    required this.message,
    required this.isMine,
  }) : super(key: key);

  @override
  State<ProductMessageBubble> createState() => _ProductMessageBubbleState();
}

class _ProductMessageBubbleState extends State<ProductMessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _productController;
  late Animation<Offset> _slideAnimation;
  late List<Animation<Offset>> _productAnimations;

  @override
  void initState() {
    super.initState();
    
    // Animation cho bubble
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Animation cho products
    _productController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Tạo animations cho từng product với delay
    _productAnimations = widget.message.menu?.asMap().entries.map((entry) {
      final index = entry.key;
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _productController,
        curve: Interval(
          (index * 0.1).clamp(0.0, 1.0),
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ));
    }).toList() ?? [];

    // Bắt đầu animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _productController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _productController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: widget.isMine 
              ? MainAxisAlignment.end 
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Không hiển thị avatar cho ProductMessageBubble (đã có avatar trong bubble)
            
            // Message bubble
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: _buildMessageBubble(),
              ),
            ),

            // Không hiển thị avatar cho ProductMessageBubble (đã có avatar trong bubble)
          ],
        ),
      ),
    );
  }

  // Avatar đã được tích hợp vào trong message bubble, không cần method riêng

  Widget _buildMessageBubble() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isMine 
            ? Colors.green.shade100 
            : widget.message.isFromEmployee
                ? Colors.blue.shade100
                : Colors.grey.shade200,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.isMine ? 20 : 4),
          topRight: Radius.circular(widget.isMine ? 4 : 20),
          bottomLeft: const Radius.circular(20),
          bottomRight: const Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: widget.isMine 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          // Sender name
          if (!widget.isMine)
            Text(
              widget.message.displayName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                letterSpacing: 0.3,
              ),
            ),
          
          if (!widget.isMine) const SizedBox(height: 8),
          
          // Message content
          if (widget.message.content.isNotEmpty)
            Text(
              widget.message.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          
          if (widget.message.content.isNotEmpty) const SizedBox(height: 16),
          
          // Products grid
          if (widget.message.hasMenu && widget.message.menu!.isNotEmpty)
            _buildProductsGrid(),
          
          const SizedBox(height: 12),
          
          // Timestamp
          Text(
            _formatTime(widget.message.timestamp.toIso8601String()),
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    final products = widget.message.menu!;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isTablet ? 2 : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final animation = index < _productAnimations.length 
            ? _productAnimations[index] 
            : null;

        Widget productCard = _buildProductCard(product);

        if (animation != null) {
          return SlideTransition(
            position: animation,
            child: productCard,
          );
        }

        return productCard;
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail
        if (product.slug != null) {
          context.go('/menumeal/${product.slug}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  child: product.image != null
                      ? Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.fastfood,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                ),
              ),
              
              // Product info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        product.title ?? 'Sản phẩm',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Price
                      if (product.price != null)
                        Text(
                          _formatPrice(product.price),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      return 'Vừa xong';
    }
  }

  String _formatPrice(dynamic price) {
    try {
      final numPrice = double.tryParse(price.toString()) ?? 0;
      return '${numPrice.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )} ₫';
    } catch (e) {
      return '0 ₫';
    }
  }
}
