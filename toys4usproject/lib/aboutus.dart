import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color pageBackground = Color(0xFFF8F5FA);

  Widget valueCard(IconData icon, String title, String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E5F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: brandColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(text, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: pageBackground,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.toys, color: Colors.white, size: 42),
                SizedBox(height: 14),
                Text(
                  "Toys 4 Us",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "A friendly toy shop built around fun, creativity, and easy shopping for families.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "What We Care About",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          valueCard(
            Icons.favorite_outline,
            "Customer Happiness",
            "We want every order to feel simple, reliable, and exciting from browsing to delivery.",
          ),
          const SizedBox(height: 10),
          valueCard(
            Icons.auto_awesome,
            "Creative Play",
            "Our Build-A-Toy experience lets customers customize plush toys and make something personal.",
          ),
          const SizedBox(height: 10),
          valueCard(
            Icons.verified_outlined,
            "Quality Products",
            "Products are organized with clear details, reviews, ratings, and prices so customers can shop confidently.",
          ),
          const SizedBox(height: 18),
          const Text(
            "Contact",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          valueCard(Icons.phone, "Phone", "(438) 555-0198"),
          const SizedBox(height: 10),
          valueCard(Icons.email_outlined, "Email", "toys4us@gmail.com"),
          const SizedBox(height: 10),
          valueCard(
            Icons.location_on_outlined,
            "Store",
            "123 Avenue Street, Montreal, QC",
          ),
        ],
      ),
    );
  }
}
