import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../Provider/MeetingProvider/NoDateMeetingProvider.dart';
import '../../compoents/responsive_helper.dart';
import 'NotdateMeetingUpdate.dart';
import '../../compoents/premium_header.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class NoDateMeetingScreen extends StatefulWidget {
  const NoDateMeetingScreen({super.key});

  @override
  State<NoDateMeetingScreen> createState() => _NoDateMeetingScreenState();
}

class _NoDateMeetingScreenState extends State<NoDateMeetingScreen> {
  String? userRole;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    Future.microtask(() {
      Provider.of<NoDateMeetingProvider>(context, listen: false)
          .fetchMeetings();
    });
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? 'user';
    });
  }

  void _refreshMeetings() {
    Provider.of<NoDateMeetingProvider>(context, listen: false).fetchMeetings();
  }

  List<dynamic> _getFilteredMeetings(NoDateMeetingProvider provider) {
    var filtered = provider.meetings;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((meeting) {
        final companyName = meeting.companyName?.toLowerCase() ?? '';
        final personName = (meeting.person?.persons.isNotEmpty ?? false)
            ? meeting.person!.persons.first.fullName?.toLowerCase() ?? ''
            : '';
        final staffName =
            meeting.person?.assignedStaff?.username?.toLowerCase() ?? '';
        final productName = meeting.product?.name?.toLowerCase() ?? '';

        return companyName.contains(query) ||
            personName.contains(query) ||
            staffName.contains(query) ||
            productName.contains(query);
      }).toList();
    }

    return filtered;
  }

  void _showDeleteDialog(BuildContext context, String meetingId,
      String companyName) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            title: Text(
              'Delete Meeting',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme
                    .of(context)
                    .colorScheme
                    .error,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to delete this meeting?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$companyName"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme
                        .of(context)
                        .brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<NoDateMeetingProvider>(context, listen: false)
                      .deleteMeeting(meetingId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Meeting deleted successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rescheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Icons.access_time_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'rescheduled':
        return Icons.calendar_today_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'With Out Follow Up',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshMeetings,
            icon: const Icon(Iconsax.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<NoDateMeetingProvider>(
        builder: (context, provider, child) {
          final filteredMeetings = _getFilteredMeetings(provider);

          return Column(
            children: [
              PremiumActionHeader(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                onAddTap: () {},
                showAdd: false,
                hintText: "Search meetings...",
              ),
              Expanded(
                child: provider.isLoading
                    ? _buildShimmerLoading(context)
                    : provider.errorMessage.isNotEmpty
                    ? _buildErrorState(provider.errorMessage, theme, isDarkMode)
                    : filteredMeetings.isEmpty
                    ? _buildEmptyState(context, _searchQuery, _searchController)
                    : _buildMeetingList(
                    context, filteredMeetings, theme, isDarkMode),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme
              .of(context)
              .brightness == Brightness.dark ? Colors.grey[800]! : Colors
              .grey[300]!,
          highlightColor: Theme
              .of(context)
              .brightness == Brightness.dark ? Colors.grey[700]! : Colors
              .grey[100]!,
          child: Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error, ThemeData theme, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 20),
          Text(
            'Error Loading Meetings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Provider
                  .of<NoDateMeetingProvider>(context, listen: false)
                  .fetchMeetings();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchQuery,
      TextEditingController searchController) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            searchQuery.isNotEmpty
                ? 'No Meetings Found'
                : 'No Pending Meetings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              searchQuery.isNotEmpty
                  ? 'No meetings match your search'
                  : 'All meetings have been scheduled or completed',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                searchController.clear();
                setState(() => _searchQuery = '');
              },
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors
                    .grey[200],
                foregroundColor: isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeetingList(BuildContext context, List<dynamic> meetings,
      ThemeData theme, bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        final personName = (meeting.person?.persons.isNotEmpty ?? false)
            ? meeting.person!.persons.first.fullName ?? "Unknown"
            : "Unknown";
        final productName = meeting.product?.name ?? "N/A";
        final staffName =
            meeting.person?.assignedStaff?.username ?? "Unassigned";
        final companyName = meeting.companyName ?? "Unknown Company";
        final status = meeting.status ?? 'Pending';
        final statusColor = _getStatusColor(status);
        final statusIcon = _getStatusIcon(status);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PremiumCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          companyName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 12, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    icon: Iconsax.user,
                    label: 'Contact Person',
                    value: personName,
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Iconsax.box,
                    label: 'Product',
                    value: productName,
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Iconsax.user_tick,
                    label: 'Assigned Staff',
                    value: staffName,
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditMeetingScreen(meeting: meeting),
                              ),
                            );
                          },
                          icon: const Icon(Iconsax.edit, size: 20,
                              color: AppTheme.primaryColor),
                          tooltip: 'Edit Meeting',
                        ),
                      ),
                      if (userRole == 'admin') ...[
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () =>
                                _showDeleteDialog(
                                    context, meeting.id ?? '', companyName),
                            icon: const Icon(
                                Iconsax.trash, size: 20, color: Colors.red),
                            tooltip: 'Delete Meeting',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}