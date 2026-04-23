import 'package:flutter/material.dart';
import '../../../compoents/premium_card.dart';
import '../../../compoents/app_theme.dart';

class StockCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final IconData icon;
  final VoidCallback? onTap;
  final String? imageUrl;

  const StockCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.icon,
    this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          // Icon or Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(icon, color: AppTheme.primaryColor))
                  : Icon(icon, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Trailing Info
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
        ],
      ),
    );
  }
}
