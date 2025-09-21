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
        childAspectRatio: 0.99, // Giảm xuống để có đủ không gian cho 5 hàng (ảnh + title + nutrition + description + price)
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
          context.go('/menu-meal/${product.slug}');
        }
      },
      onLongPress: () {
        // Show detailed info overlay
        _showProductDetails(product);
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product image với AspectRatio cố định
              AspectRatio(
                aspectRatio: 1.4, // Giảm từ 1.6 xuống 1.4 để ảnh ngắn hơn
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
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  product.title ?? 'Product',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Nutrition info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  [
                    if (product.calo != null) '${product.calo!.round()} cal',
                    if (product.protein != null) '${product.protein!.toStringAsFixed(1)}g protein',
                    if (product.carb != null) '${product.carb!.toStringAsFixed(1)}g carbs',
                    if (product.fat != null) '${product.fat!.toStringAsFixed(1)}g fat',
                  ].join(' • '),
                        style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  product.description ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2, // Tăng từ 1 lên 2 để hiển thị đầy đủ hơn
                  overflow: TextOverflow.ellipsis,
                ),
              ),
                      
                      // Price
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  product.price != null ? _formatPriceVND(product.price) : 'Price not available',
                  style: const TextStyle(
                    fontSize: 13,
                            fontWeight: FontWeight.w600,
                    color: Colors.black,
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
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  String _formatPriceVND(dynamic price) {
    try {
      final numPrice = double.tryParse(price.toString()) ?? 0;
      return '${numPrice.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )} VND';
    } catch (e) {
      return '0 VND';
    }
  }

  void _showProductDetails(dynamic product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.title ?? 'Product Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Description
                if (product.description != null && product.description.isNotEmpty) ...[
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(product.description),
                  const SizedBox(height: 16),
                ],
                
                // Nutrition info
                const Text(
                  'Nutrition Information:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildNutritionItem(
                        'Calories',
                        product.calo?.round().toString() ?? 'N/A',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildNutritionItem(
                        'Protein',
                        product.protein?.toStringAsFixed(1) ?? 'N/A',
                        Icons.fitness_center,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildNutritionItem(
                        'Carbs',
                        product.carb?.toStringAsFixed(1) ?? 'N/A',
                        Icons.grain,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildNutritionItem(
                        'Fat',
                        product.fat?.toStringAsFixed(1) ?? 'N/A',
                        Icons.opacity,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                // Price
                const SizedBox(height: 16),
                const Text(
                  'Price:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  product.price != null ? _formatPriceVND(product.price) : 'Price not available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                
                // Allergens
                if (product.menuIngredient != null && product.menuIngredient!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Allergy Information:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: product.menuIngredient!.map((ingredient) {
                      return Chip(
                        label: Text(
                          _getAllergenDisplayName(ingredient.name),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.red.shade50,
                        labelStyle: TextStyle(color: Colors.red.shade700),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (product.slug != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/menu-meal/${product.slug}');
                },
                child: const Text('View Details'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildNutritionItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _getAllergenDisplayName(String allergen) {
    switch (allergen) {
      case 'GLUTEN':
        return 'Gluten';
      case 'PEANUTS':
        return 'Peanuts';
      case 'TREE_NUTS':
        return 'Tree Nuts';
      case 'DAIRY':
        return 'Dairy';
      case 'EGG':
        return 'Egg';
      case 'SOY':
        return 'Soy';
      case 'FISH':
        return 'Fish';
      case 'SHELLFISH':
        return 'Shellfish';
      case 'SESAME':
        return 'Sesame';
      case 'CELERY':
        return 'Celery';
      case 'MUSTARD':
        return 'Mustard';
      case 'LUPIN':
        return 'Lupin';
      case 'MOLLUSCS':
        return 'Molluscs';
      case 'SULPHITES':
        return 'Sulphites';
      default:
        return allergen;
    }
  }
}
