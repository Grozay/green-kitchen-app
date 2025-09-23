import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:provider/provider.dart';
import '../../models/menu_meal_review.dart';
import '../../provider/auth_provider.dart';

class ReviewListWidget extends StatefulWidget {
  final List<MenuMealReview> reviews;
  final bool reviewsLoading;
  final Function(MenuMealReview) onEdit;

  const ReviewListWidget({
    super.key,
    required this.reviews,
    required this.reviewsLoading,
    required this.onEdit,
  });

  @override
  State<ReviewListWidget> createState() => _ReviewListWidgetState();
}

class _ReviewListWidgetState extends State<ReviewListWidget> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (widget.reviewsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.reviews.isEmpty) {
      return const Text('No reviews yet. Be the first to review this dish!');
    }

    return Column(
      children: widget.reviews
          .map<Widget>(
            (review) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: review.customer?.avatar != null
                                ? NetworkImage(review.customer!.avatar!)
                                : null,
                            child: review.customer?.avatar == null
                                ? Text(review.customerName[0])
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                StarRating(
                                  rating: review.rating.toDouble(),
                                  onRatingChanged: null,
                                  starCount: 5,
                                  size: 16.0,
                                  color: Colors.amber,
                                  borderColor: Colors.grey,
                                  allowHalfRating: true,
                                ),
                              ],
                            ),
                          ),
                          if (review.customerId ==
                              int.tryParse(authProvider.currentUser?.id ?? ''))
                            const Text(
                              ' (Your review)',
                              style: TextStyle(color: Colors.blue),
                            ),
                          const SizedBox(width: 8),
                          if (review.customerId ==
                              int.tryParse(authProvider.currentUser?.id ?? ''))
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => widget.onEdit(review),
                            ),
                        ],
                      ),
                      Text(review.comment),
                      Text(
                        review.createdAt ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
