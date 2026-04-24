import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'app_theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? radius;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.radius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        margin: margin,
        decoration: AppTheme.premiumCardDecoration(context, color: color, radius: radius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius ?? AppTheme.cardRadius),
          child: child,
        ),
      ),
    );
  }
}

class PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const PremiumStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PremiumWideStatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;

  const PremiumWideStatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumEntityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? image;
  final Widget? badge;
  final List<Widget> details;
  final String? id;
  final VoidCallback? onTap;
  final Color? accentColor;

  const PremiumEntityCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.image,
    this.badge,
    required this.details,
    this.id,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = accentColor ?? AppTheme.primaryColor;

    return PremiumCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      radius: AppTheme.cardRadius,
      child: Container(
        constraints: const BoxConstraints(minHeight: 130),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Image Section
              Container(
                width: 120,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.cardRadius),
                    bottomLeft: Radius.circular(AppTheme.cardRadius),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.cardRadius),
                    bottomLeft: Radius.circular(AppTheme.cardRadius),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (image != null && image!.isNotEmpty)
                        Image.network(
                          image!,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(primary),
                        )
                      else
                        _buildPlaceholder(primary),
                      
                      // ID Badge
                      if (id != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              id!,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Right Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (badge != null) badge!,
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: 12),
                      ...details.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: d,
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.user, color: color.withOpacity(0.4), size: 32),
          const SizedBox(height: 4),
          Text(
            title.isNotEmpty ? title[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
