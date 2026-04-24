import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'app_theme.dart';

class PremiumActionHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddTap;
  final String hintText;
  final bool showAdd;

  const PremiumActionHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onAddTap,
    this.hintText = "Search...",
    this.showAdd = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Iconsax.search_normal, size: 18, color: AppTheme.primaryColor.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          if (showAdd) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onAddTap,
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Iconsax.add, color: Colors.white, size: 24),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
