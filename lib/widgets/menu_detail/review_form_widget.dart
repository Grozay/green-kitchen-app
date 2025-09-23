import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import '../../models/menu_meal_review.dart';

class ReviewFormWidget extends StatefulWidget {
  final bool hasPurchased;
  final bool submittingReview;
  final double rating;
  final TextEditingController commentController;
  final Function(double) onRatingChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final bool hasAlreadyReviewed;
  final MenuMealReview? editingReview; // Thêm parameter cho editing

  const ReviewFormWidget({
    super.key,
    required this.hasPurchased,
    required this.submittingReview,
    required this.rating,
    required this.commentController,
    required this.onRatingChanged,
    required this.onSubmit,
    required this.onCancel,
    required this.hasAlreadyReviewed,
    this.editingReview, // Optional parameter
  });

  @override
  State<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

class _ReviewFormWidgetState extends State<ReviewFormWidget> {
  late String _commentText;

  @override
  void initState() {
    super.initState();
    _commentText = widget.commentController.text;
  }

  @override
  void didUpdateWidget(covariant ReviewFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync comment text when widget updates (e.g., when editing review)
    if (oldWidget.commentController.text != widget.commentController.text) {
      _commentText = widget.commentController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingReview != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Update Review' : 'Write a Review',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          // Chỉ hiện rating form khi chưa rating (rating = 0) hoặc đang edit
          if (widget.rating == 0.0 || isEditing)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Rating:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                StarRating(
                  rating: widget.rating,
                  onRatingChanged: isEditing ? null : widget.onRatingChanged, // Disable khi edit
                  starCount: 5,
                  size: 24.0,
                  color: Colors.amber,
                  borderColor: Colors.grey,
                  allowHalfRating: true,
                ),
                if (isEditing)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Rating cannot be changed when editing review',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),

          // Hiển thị rating đã chọn khi đã rating và không phải edit
          if (widget.rating > 0.0 && !isEditing)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Rating:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StarRating(
                      rating: widget.rating,
                      onRatingChanged: null, // Read-only
                      starCount: 5,
                      size: 24.0,
                      color: Colors.amber,
                      borderColor: Colors.grey,
                      allowHalfRating: true,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.rating.toStringAsFixed(1)}/5.0',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.commentController,
            maxLines: 4,
            onChanged: (value) {
              setState(() {
                _commentText = value;
                widget.commentController.text = value; // Đồng bộ với controller từ parent
              });
            },
            decoration: InputDecoration(
              hintText: isEditing ? 'Update your comment...' : 'Your comment...',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: widget.submittingReview
                    ? null
                    : _commentText.trim().isNotEmpty
                        ? widget.onSubmit
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  widget.submittingReview
                      ? (isEditing ? 'Updating...' : 'Submitting...')
                      : (isEditing ? 'Update Review' : 'Submit Review'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: widget.onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}