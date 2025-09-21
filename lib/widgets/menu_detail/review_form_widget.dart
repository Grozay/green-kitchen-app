import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';

class ReviewFormWidget extends StatefulWidget {
  final bool hasPurchased;
  final bool submittingReview;
  final double rating;
  final TextEditingController commentController;
  final Function(double) onRatingChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final bool hasAlreadyReviewed; // Thêm tham số để kiểm tra đã review chưa

  const ReviewFormWidget({
    super.key,
    required this.hasPurchased,
    required this.submittingReview,
    required this.rating,
    required this.commentController,
    required this.onRatingChanged,
    required this.onSubmit,
    required this.onCancel,
    required this.hasAlreadyReviewed, // Thêm vào constructor
  });

  @override
  State<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

class _ReviewFormWidgetState extends State<ReviewFormWidget> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.currentUser == null) {
      return const Text('Please login to write a review');
    }

    if (!widget.hasPurchased) {
      return const Text('Purchase this item first to leave a review');
    }

    if (widget.hasAlreadyReviewed) {
      return const Text('You have already reviewed this item.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Write a Review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StarRating(
          rating: widget.rating,
          onRatingChanged: widget.onRatingChanged, // Không disable
          starCount: 5,
          size: 24.0,
          color: Colors.amber,
          borderColor: Colors.grey,
          allowHalfRating: true,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.commentController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Your comment...'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: widget.submittingReview ? null : widget.onSubmit,
              child: const Text('Submit Review'),
            ),
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}