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

class GridStockCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String? status;
  final String? imageUrl;

  const GridStockCard({
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
    return PremiumCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      radius: AppTheme.cardRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Image Section
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),
                  
                  if (status != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildStatusBadge(status!),
                    ),
                ],
              ),
            ),
          ),
          
          // Bottom Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (trailing != null)
                      Text(
                        trailing!,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor, fontSize: 13),
                      )
                    else
                      const SizedBox(),
                    
                    if (onDelete != null)
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Iconsax.trash, size: 14, color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.box, color: AppTheme.primaryColor.withOpacity(0.4), size: 28),
          const SizedBox(height: 4),
          Text(
            title.isNotEmpty ? title[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
