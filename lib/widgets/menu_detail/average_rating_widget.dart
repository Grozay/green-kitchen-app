import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';

class AverageRatingWidget extends StatelessWidget {
  final double averageRating;
  final int reviewCount;

  const AverageRatingWidget({
    super.key,
    required this.averageRating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Rating: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Thay bằng AppColors.textPrimary nếu cần
          ),
        ),
        StarRating(
          rating: averageRating,
          onRatingChanged: null,
          starCount: 5,
          size: 20.0,
          color: Colors.amber,
          borderColor: Colors.grey,
          allowHalfRating: true,
        ),
        const SizedBox(width: 8),
        Text(
          '${averageRating.toStringAsFixed(1)} ($reviewCount reviews)',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey, // Thay bằng AppColors.textSecondary
          ),
        ),
      ],
    );
  }
}