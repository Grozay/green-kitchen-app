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
                            onPressed: () {
                              double tempRating = review.rating.toDouble();
                              TextEditingController commentController =
                                  TextEditingController(text: review.comment);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Edit Review'),
                                  content: SizedBox(
                                    height: 300,
                                    child: Column(
                                      children: [
                                        StarRating(
                                          rating: tempRating,
                                          onRatingChanged: (newRating) {
                                            setState(() => tempRating = newRating);
                                          },
                                          starCount: 5,
                                          size: 24.0,
                                          color: Colors.amber,
                                          borderColor: Colors.grey,
                                          allowHalfRating: true,
                                        ),
                                        TextField(
                                          controller: commentController,
                                          maxLines: 4,
                                          decoration: const InputDecoration(
                                              hintText: 'Your comment...'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        final updatedReview = MenuMealReview(
                                          id: review.id,
                                          customerId: review.customerId,
                                          customerName: review.customerName,
                                          rating: tempRating.toInt(),
                                          comment: commentController.text,
                                          createdAt: review.createdAt,
                                          menuMealId: review.menuMealId,
                                          menuMealTitle: review.menuMealTitle, // Thêm tham số này
                                        );
                                        widget.onEdit(updatedReview);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Update'),
                                    ),
                                  ],
                                ),
                              );
                            },
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
          )
          .toList(),
    );
  }
}
