import 'package:flutter/material.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';


class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String selectedCategory = '';
  String search = '';

  final List<Map<String, dynamic>> categories = [
    {'name': 'Technology'},
    {'name': 'Health'},
    {'name': 'Food'},
    {'name': 'Travel'},
    {'name': 'Lifestyle'},
  ];

  final List<Map<String, dynamic>> posts = [
    {
      'title': 'Latest Tech Trends in 2023',
      'category': 'Technology',
      'excerpt': 'Exploring the future of tech.',
      'author': 'Admin',
      'image': 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Ultimate Health Guide',
      'category': 'Health',
      'excerpt': 'Tips for a healthier lifestyle.',
      'author': 'Dr. Smith',
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Easy Vegan Recipes',
      'category': 'Food',
      'excerpt': 'Vegan cooking made simple.',
      'author': 'Chef Anna',
      'image': 'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Top Travel Destinations',
      'category': 'Travel',
      'excerpt': 'Top spots for travelers.',
      'author': 'Traveler Joe',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Work-Life Balance Tips',
      'category': 'Lifestyle',
      'excerpt': 'Achieving work-life balance.',
      'author': 'Coach Linh',
      'image': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPosts = posts.where((post) {
      final matchesCategory = selectedCategory.isEmpty || post['category'] == selectedCategory;
      final matchesSearch = search.isEmpty || post['title'].toLowerCase().contains(search.toLowerCase()) || post['excerpt'].toLowerCase().contains(search.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return NavBar(
      cartCount: 3,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const SizedBox(height: 8),
              // const Text(
              //   'GREEN\nKITCHEN',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     color: Color(0xFF1CC29F),
              //     fontWeight: FontWeight.bold,
              //     fontSize: 28,
              //     letterSpacing: 1.2,
              //   ),
              // ),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Green\n',
                      style: TextStyle(
                        color: Color(0xFF4B0036),
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'ARTICLES',
                      style: TextStyle(
                        color: Color(0xFF1CC29F),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Read helpful articles, recipes and tips\nfrom our community.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search articles, recipes, topics...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => search = value),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose Topic:',
                  style: TextStyle(
                    color: Color(0xFF4B0036),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat['name'];
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFF1CC29F).withOpacity(0.1) : Colors.transparent,
                      side: BorderSide(color: const Color(0xFF4B0036)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => setState(() => selectedCategory = isSelected ? '' : cat['name']),
                    child: Text(
                      cat['name'],
                      style: TextStyle(
                        color: const Color(0xFF4B0036),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              if (filteredPosts.isEmpty)
                const Text('No posts found', style: TextStyle(color: Colors.grey)),
              ...filteredPosts.map((post) => _PostCard(post: post)).toList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post['image'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1CC29F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post['excerpt'],
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      Text(
                        post['author'],
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      Icon(Icons.category, size: 16, color: Colors.grey[600]),
                      Text(
                        post['category'],
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
