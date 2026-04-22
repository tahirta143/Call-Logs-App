import 'package:flutter/material.dart';
import 'package:infinity/Provider/auth/access_control_provider.dart';
import 'package:infinity/Provider/theme/theme_provider.dart';

import 'package:infinity/View/home/weekly_charts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../Provider/dashboard/dashboard_provider.dart';
import '../../compoents/responsive_helper.dart';
// import '../../compoents/premium_header.dart';
import '../../compoents/premium_card.dart';
import 'package:iconsax/iconsax.dart';
import '../../helpers/permission_helper.dart';
import '../monthly chats.dart';
import '../staff/staffListScreen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? userRole;
  List<String> userPermissions = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<DashBoardProvider>(context, listen: false);
      provider.loadAllDashboardData();
    });
  }

  Widget build(BuildContext context) {
    final acp = Provider.of<AccessControlProvider>(context);
    final provider = Provider.of<DashBoardProvider>(context);

    if (acp.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return provider.isLoading
        ? _buildShimmerLoading()
        : RefreshIndicator(
            onRefresh: () async {
              await provider.loadAllDashboardData();
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  _buildWelcomeHeader(provider),

                  // Statistics Cards
                  _buildStatisticsCards(provider, acp),

                  // Performance Section
                  _buildPerformanceSection(provider),

                  // React Dasbhoard Data Implementations
                  _buildSecurityProtocolSection(),
                  const SizedBox(height: 16),
                  _buildRecentActivitySection(),

                  // Follow-up Calendar
                  _buildCalendarSection(provider),

                  // Charts Section
                  _buildChartsSection(provider),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Statistics cards shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Row(
            children: List.generate(
                2,
                (index) => Expanded(
                      child: Container(
                        height: 120,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )),
          ),
        ),
        const SizedBox(height: 20),

        // Performance shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(DashBoardProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello!',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome to Infinity Dashboard',
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.totalCalls} Total Calls | ${provider.totalCustomers} Customers',
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.8) : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.chart_3,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(DashBoardProvider provider, AccessControlProvider acp) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cards = [


      {
        'icon': Iconsax.people,
        'title': 'Staff',
        'count': provider.totalStaffs.toString(),
        'color': const Color(0xFF2196F3),
        'onTap': acp.canRead('EMPLOYEE.EMPLOYEE')
            ? () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StaffScreen()),
        )
            : null,
      },
      {
        'icon': Iconsax.receipt,
        'title': 'Transactions',
        'count': provider.totalTransactions.toString(),
        'color': const Color(0xFFFF9800),
        'onTap': null,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return PremiumCard(
            onTap: card['onTap'] != null
                ? () => card['onTap']!
                : () {
              if (card['onTap'] == null && card['title'] != 'Customers') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${card['title']}: Access restricted"),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (card['color'] as Color).withOpacity(0.2),
                        (card['color'] as Color).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    card['icon'] as IconData,
                    color: card['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    card['count'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    card['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerformanceSection(DashBoardProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Helper function to safely parse any value to double
    double _safeParseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Remove any percentage signs and parse
        String cleanValue = value.toString().replaceAll('%', '').trim();
        return double.tryParse(cleanValue) ?? 0.0;
      }
      return 0.0;
    }

    final metrics = [
      {
        'label': 'Success Rate',
        'value': _safeParseToDouble(provider.successRate),
        'max': 100.0,
        'color': const Color(0xFF4CAF50),
        'icon': Iconsax.trend_up,
      },
      {
        'label': 'Pending Calls',
        'value': _safeParseToDouble(provider.pendingCalls),
        'max': 100.0,
        'color': const Color(0xFF2196F3),
        'icon': Iconsax.clock,
      },
      {
        'label': 'Follow Ups',
        'value': _safeParseToDouble(provider.followUps),
        'max': 100.0,
        'color': const Color(0xFFFF9800),
        'icon': Iconsax.refresh,
      },
      // {
      //   'label': 'Meetings',
      //   'value': _safeParseToDouble(provider.totalMeetings),
      //   'max': provider.totalMeetings > 100
      //       ? _safeParseToDouble(provider.totalMeetings)
      //       : 100.0,
      //   'color': const Color(0xFF9C27B0),
      //   'icon': Iconsax.calendar,
      // },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.chart_2, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Performance Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  'Updated just now',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.spaceEvenly,
              children: metrics.map((metric) {
                final value = metric['value'] as double;
                final max = metric['max'] as double;
                final percent = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;

                return Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 8,
                            backgroundColor:
                            (metric['color'] as Color).withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                metric['color'] as Color),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          children: [
                            Icon(
                              metric['icon'] as IconData,
                              color: metric['color'] as Color,
                              size: 20,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${value.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (metric['label'] != 'Meetings')
                              Text(
                                '%',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      metric['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityProtocolSection() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.shield_tick, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            const Text(
              'Security Protocol',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All system modules are currently operating under standard security monitoring.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'System Status',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.75, // 75% active just like React
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activities = [
      {'user': 'Sarah Jenkins', 'action': 'Created new employee profile', 'time': '2 mins ago', 'icon': Iconsax.tick_circle, 'color': Colors.green},
      {'user': 'System Admin', 'action': 'Updated security permissions', 'time': '15 mins ago', 'icon': Iconsax.shield, 'color': theme.colorScheme.primary},
      {'user': 'John Doe', 'action': 'Failed login attempt detected', 'time': '1 hour ago', 'icon': Iconsax.warning_2, 'color': Colors.red},
      {'user': 'HR Manager', 'action': 'Approved leave request', 'time': '3 hours ago', 'icon': Iconsax.clock, 'color': Colors.orange},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time system event log',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (activity['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        activity['icon'] as IconData,
                        color: activity['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['user'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activity['action'] as String,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity['time'] as String,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'View All Activity',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(DashBoardProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.calendar_1,
                    color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Follow-up Calendar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.totalMeetings} Meetings',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CalendarWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(DashBoardProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Trends
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.chart_success,
                        color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Monthly Trends',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.totalCalls} Total Calls',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                provider.monthlyTrends.isEmpty
                    ? Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.chart_fail,
                            color: Colors.grey, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'No data available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
                    : MonthlyTrendsChart(
                  totalCalls: provider.totalCalls,
                  monthlyData: provider.monthlyTrends,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Weekly Volume
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.chart_21,
                        color: Color(0xFF5B86E5), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly Performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${provider.totalWeeklyCalls} calls this week',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                WeeklyVolumeChart(
                  totalCalls: provider.totalWeeklyCalls,
                  weeklyData: provider.weeklyData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Updated AnimatedDashboardCard with shimmer
// Updated AnimatedDashboardCard with shimmer
class AnimatedDashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String count;
  final Color bcolor;
  final VoidCallback? onTap;

  const AnimatedDashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.bcolor,
    this.onTap,
  });

  @override
  State<AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
}

class _AnimatedDashboardCardState extends State<AnimatedDashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 120,
            maxHeight: 140,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.bcolor,
                widget.bcolor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.bcolor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 30,
                color: widget.bcolor,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  widget.count,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class _AnimatedDashboardCardState extends State<AnimatedDashboardCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       onTapDown: (_) => _controller.forward(),
//       onTapUp: (_) => _controller.reverse(),
//       onTapCancel: () => _controller.reverse(),
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 widget.bcolor,
//                 widget.bcolor.withOpacity(0.8),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: widget.bcolor.withOpacity(0.3),
//                 blurRadius: 15,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 widget.icon,
//                 size: 36,
//                 color: Colors.white,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 widget.count,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// Updated CalendarWidget with modern styling
class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashBoardProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
          leftChevronIcon:
          const Icon(Iconsax.arrow_left_2, color: Color(0xFF5B86E5)),
          rightChevronIcon:
          const Icon(Iconsax.arrow_right_3, color: Color(0xFF5B86E5)),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          todayTextStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          selectedDecoration: BoxDecoration(
            color: const Color(0xFF5B86E5).withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.white),
          defaultTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
          weekendTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
          outsideDaysVisible: false,
          cellMargin: const EdgeInsets.all(4),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            bool isMeeting = provider.isMeetingDay(day);
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isMeeting ? Colors.green.withValues(alpha: 0.9) : null,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isMeeting ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isMeeting ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
