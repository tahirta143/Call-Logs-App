import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CustomersTrackScreen.dart';
import 'FollowUpTrackScreen.dart';
import 'MeetingTrackScreen.dart';
import 'StaffTrackScreen.dart';
import '../../compoents/responsive_helper.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class ActivityTrackScreen extends StatefulWidget {
  const ActivityTrackScreen({super.key});

  @override
  State<ActivityTrackScreen> createState() => _ActivityTrackScreenState();
}

class _ActivityTrackScreenState extends State<ActivityTrackScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Activity Tracking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTrackItem(
                icon: Iconsax.profile_2user,
                title: 'Customers Track',
                details: 'Monitor Customer Create, Update and assignments',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomersTrackScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _buildTrackItem(
                icon: Iconsax.status,
                title: 'Meeting Track',
                details: 'Track meeting schedules and progress',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MeetingTrackScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _buildTrackItem(
                icon: Iconsax.document_text,
                title: 'Follow Up Track',
                details: 'See recent follow-ups and status',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FollowUpTrackScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _buildTrackItem(
                icon: Iconsax.user,
                title: 'Staff Track',
                details: 'Monitor staff activity and engagement',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StaffTrackScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTrackItem({
    required IconData icon,
    required String title,
    required String details,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PremiumCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
