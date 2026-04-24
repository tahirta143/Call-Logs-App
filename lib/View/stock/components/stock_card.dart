import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../compoents/premium_card.dart';
import '../../../compoents/app_theme.dart';

class StockCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String? status;
  final String? imageUrl;

  const StockCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.icon,
    this.onTap,
    this.onDelete,
    this.status,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumEntityCard(
      title: title,
      subtitle: subtitle,
      image: imageUrl,
      onTap: onTap,
      badge: status != null ? _buildStatusBadge(status!) : null,
      details: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor, fontSize: 14),
              ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.trash, size: 16, color: Colors.red),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'inactive': return Colors.red;
      case 'pending': return Colors.orange;
      default: return AppTheme.primaryColor;
    }
  }
}
