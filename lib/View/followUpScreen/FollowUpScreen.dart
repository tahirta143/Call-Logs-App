import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../Provider/FollowUp/FollowupProvider.dart';
import '../../compoents/premium_header.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import '../../compoents/responsive_helper.dart';
import '../../model/FollowUpModel.dart';

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  String? userRole;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _showFloatingButton = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    Future.microtask(() {
      final provider = Provider.of<FollowUpProvider>(context, listen: false);
      provider.fetchFollowUps();
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? 'user';
    });
  }

  void _scrollListener() {
    if (_scrollController.offset > 100) {
      if (_showFloatingButton) {
        setState(() => _showFloatingButton = false);
      }
    } else {
      if (!_showFloatingButton) {
        setState(() => _showFloatingButton = true);
      }
    }
  }

  void _refreshFollowUps() {
    Provider.of<FollowUpProvider>(context, listen: false).fetchFollowUps();
  }

  List<String> _getStatusTypes(FollowUpProvider provider) {
    final types = provider.followUps
        .map((item) => item.status)
        .where((status) => status != null && status.isNotEmpty)
        .toSet()
        .toList()
        .cast<String>();
    return ['All', ...types];
  }

  List<FollowUpData> _getFilteredFollowUps(FollowUpProvider provider) {
    var filtered = provider.followUps;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        final companyName = item.companyName.toLowerCase();
        final staffName = item.person?.assignedStaff?.username?.toLowerCase() ?? '';
        final phoneNumber = (item.person?.persons.isNotEmpty ?? false)
            ? item.person!.persons.first.phoneNumber?.toLowerCase() ?? ''
            : '';
        final status = item.status?.toLowerCase() ?? '';

        return companyName.contains(query) ||
            staffName.contains(query) ||
            phoneNumber.contains(query) ||
            status.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((item) {
        return item.status == _selectedFilter;
      }).toList();
    }

    return filtered;
  }

  void _showDeleteDialog(BuildContext context, String followUpId, String companyName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          'Delete Follow-up',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete follow-up for "$companyName"?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
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
              Provider.of<FollowUpProvider>(context, listen: false)
                  .deleteFollowUp(followUpId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Follow-up deleted successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
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
      case 'complete':
        return Colors.green;
      case 'hold':
        return Colors.orange;
      case 'close':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'complete':
        return Icons.check_circle_rounded;
      case 'hold':
        return Icons.pause_circle_rounded;
      case 'close':
        return Icons.cancel_rounded;
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
        title: const Text('Follow-ups', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshFollowUps,
            icon: const Icon(Iconsax.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<FollowUpProvider>(
        builder: (context, provider, child) {
          final filteredFollowUps = _getFilteredFollowUps(provider);
          final totalPages = (filteredFollowUps.length / _itemsPerPage).ceil();
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = startIndex + _itemsPerPage > filteredFollowUps.length
              ? filteredFollowUps.length
              : startIndex + _itemsPerPage;
          final paginatedList = filteredFollowUps.sublist(startIndex, endIndex);
          final statusTypes = _getStatusTypes(provider);

          return Column(
            children: [
              PremiumActionHeader(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                onAddTap: () {}, // Not used here
                showAdd: false,
                hintText: "Search follow-ups...",
              ),
              if (provider.followUps.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: statusTypes.map((status) {
                      final isSelected = _selectedFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedFilter = status);
                          },
                          backgroundColor: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide.none,
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              Expanded(
                child: provider.isLoading
                    ? _buildShimmerLoading()
                    : provider.errorMessage != null
                    ? _buildErrorState(provider.errorMessage!, theme, isDarkMode)
                    : filteredFollowUps.isEmpty
                    ? _buildEmptyState(context, _searchQuery, _searchController)
                    : _buildFollowUpList(context, paginatedList, totalPages, theme, isDarkMode),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
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
            'Error Loading Follow-ups',
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
              Provider.of<FollowUpProvider>(context, listen: false).fetchFollowUps();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchQuery, TextEditingController searchController) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            searchQuery.isNotEmpty ? 'No Follow-ups Found' : 'No Follow-ups',
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
                  ? 'No follow-ups match your search'
                  : 'All follow-ups have been completed or closed',
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
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                foregroundColor: isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFollowUpList(BuildContext context, List<FollowUpData> followUps,
      int totalPages, ThemeData theme, bool isDarkMode) {
    final provider = Provider.of<FollowUpProvider>(context, listen: false);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: followUps.length,
            itemBuilder: (context, index) {
              final item = followUps[index];
              final staffName = item.person?.assignedStaff?.username ?? 'Unassigned';
              final date = item.followDates.isNotEmpty
                  ? item.followDates.first.split('T').first
                  : '-';
              final time = item.followTimes.isNotEmpty
                  ? item.followTimes.first
                  : '-';
              final phoneNumber = (item.person?.persons.isNotEmpty ?? false)
                  ? item.person!.persons.first.phoneNumber ?? '-'
                  : '-';
              final companyName = item.companyName;
              final status = item.status ?? 'Hold';
              final statusColor = _getStatusColor(status);
              final statusIcon = _getStatusIcon(status);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PremiumCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with company name and status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 14,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Follow-up details
                        _buildDetailRow(
                          icon: Iconsax.user,
                          label: 'Assigned Staff',
                          value: staffName,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          icon: Iconsax.call,
                          label: 'Contact Number',
                          value: phoneNumber,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(
                                icon: Iconsax.calendar_1,
                                label: 'Date',
                                value: date,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailRow(
                                icon: Iconsax.clock,
                                label: 'Time',
                                value: time,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],
                        ),

                        if (item.action != null && item.action!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Iconsax.note_text,
                            label: 'Next Action',
                            value: item.action!,
                            isDarkMode: isDarkMode,
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildActionButton(
                              icon: Iconsax.eye,
                              color: AppTheme.primaryColor,
                              onTap: () => _showDetailsDialog(context, item),
                              tooltip: 'View Details',
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              icon: Iconsax.edit_2,
                              color: AppTheme.primaryColor,
                              onTap: () => _showUpdateDialog(context, item, provider),
                              tooltip: 'Edit Follow-up',
                            ),
                            if (userRole == 'admin') ...[
                              const SizedBox(width: 12),
                              _buildActionButton(
                                icon: Iconsax.trash,
                                color: Colors.red,
                                onTap: () => _showDeleteDialog(
                                  context,
                                  item.id,
                                  companyName,
                                ),
                                tooltip: 'Delete',
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
          ),
        ),
        // Pagination
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _currentPage > 0
                      ? () {
                    setState(() => _currentPage--);
                  }
                      : null,
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Previous'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Page ${_currentPage + 1} of $totalPages',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _currentPage < totalPages - 1
                      ? () {
                    setState(() => _currentPage++);
                  }
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16), label: const Text('Next'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onTap,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }
  //   );
  //   final dateController = TextEditingController(
  //     text: item.followDates.isNotEmpty
  //         ? item.followDates.first.split('T').first
  //         : '',
  //   );
  //   final timeController = TextEditingController(
  //     text: item.followTimes.isNotEmpty ? item.followTimes.first : '',
  //   );
  //   final remarkController = TextEditingController(text: item.action ?? '');
  //
  //   final validStatuses = ['Complete', 'Hold', 'Close'];
  //   String status = item.status ?? 'Hold';
  //
  //   final theme = Theme.of(context);
  //   final isDarkMode = theme.brightness == Brightness.dark;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
  //         surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
  //         title: Text(
  //           'Update Follow-up',
  //           style: TextStyle(
  //             color: theme.colorScheme.primary,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: SizedBox(
  //           width: MediaQuery.of(context).size.width * 0.9,
  //           child: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 _buildDialogTextField(
  //                   controller: companyController,
  //                   label: 'Company Name',
  //                   icon: Icons.business_rounded,
  //                   theme: theme,
  //                   isDarkMode: isDarkMode,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildDialogTextField(
  //                   controller: phoneController,
  //                   label: 'Phone Number',
  //                   icon: Icons.phone_rounded,
  //                   keyboardType: TextInputType.phone,
  //                   theme: theme,
  //                   isDarkMode: isDarkMode,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildDatePickerField(
  //                   controller: dateController,
  //                   label: 'Next Follow-up Date',
  //                   theme: theme,
  //                   context: context,
  //                   isDarkMode: isDarkMode,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildTimePickerField(
  //                   controller: timeController,
  //                   label: 'Next Follow-up Time',
  //                   theme: theme,
  //                   context: context,
  //                   isDarkMode: isDarkMode,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildDialogTextField(
  //                   controller: remarkController,
  //                   label: 'Customer Remark',
  //                   icon: Icons.comment_rounded,
  //                   maxLines: 3,
  //                   theme: theme,
  //                   isDarkMode: isDarkMode,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildStatusDropdown(
  //                   value: status,
  //                   items: validStatuses,
  //                   theme: theme,
  //                   isDarkMode: isDarkMode,
  //                   onChanged: (value) {
  //                     if (value != null) status = value;
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               provider.updateFollowUp(
  //                 id: item.id,
  //                 companyName: companyController.text,
  //                 phone: phoneController.text,
  //                 date: dateController.text,
  //                 time: timeController.text,
  //                 remark: remarkController.text,
  //                 status: status,
  //               );
  //               Navigator.pop(context);
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: const Text('Follow-up updated successfully'),
  //                   backgroundColor: Colors.green,
  //                   behavior: SnackBarBehavior.floating,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //               );
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: theme.colorScheme.primary,
  //               foregroundColor: Colors.white,
  //             ),
  //             child: const Text('Update'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }



  // void _showUpdateDialog(BuildContext context, FollowUpData item, FollowUpProvider provider) {
  //   final companyController = TextEditingController(text: item.companyName ?? '');
  //   final phoneController = TextEditingController(
  //     text: (item.person?.persons.isNotEmpty ?? false)
  //         ? item.person!.persons.first.phoneNumber ?? ''
  //         : '',
  //   );
  //   final dateController = TextEditingController(
  //     text: item.followDates.isNotEmpty
  //         ? item.followDates.first.split('T').first
  //         : '',
  //   );
  //   final timeController = TextEditingController(
  //     text: item.followTimes.isNotEmpty ? item.followTimes.first : '',
  //   );
  //   final remarkController = TextEditingController(text: item.action ?? '');
  //
  //   // Define unique statuses - make sure there are no duplicates
  //   final validStatuses = ['Complete', 'Hold', 'Close'];
  //   String status = item.status ?? 'Hold';
  //
  //   // Add current status if not already in the list
  //   if (status.isNotEmpty && !validStatuses.contains(status)) {
  //     validStatuses.add(status);
  //   }
  //
  //   final theme = Theme.of(context);
  //   final isDarkMode = theme.brightness == Brightness.dark;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
  //         surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
  //         title: Text(
  //           'Update Follow-up',
  //           style: TextStyle(
  //             color: theme.colorScheme.primary,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: SizedBox(
  //           width: MediaQuery.of(context).size.width * 0.9,
  //           child: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 _buildDialogTextField(
  //                   controller: companyController,
  //                   label: 'Company Name',
  //                   icon: Icons.business_rounded,
  //                   theme: theme,
  //                   isDarkMode: isDarkMode,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildDialogTextField(
  //                   controller: phoneController,
  //                   label: 'Phone Number',
  //                   icon: Icons.phone_rounded,
  //                   keyboardType: TextInputType.phone,
  //                   theme: theme,
  //                   isDarkMode: isDarkMode,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildDatePickerField(
  //                   controller: dateController,
  //                   label: 'Next Follow-up Date',
  //                   theme: theme,
  //                   context: context,
  //                   isDarkMode: isDarkMode,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildTimePickerField(
  //                   controller: timeController,
  //                   label: 'Next Follow-up Time',
  //                   theme: theme,
  //                   context: context,
  //                   isDarkMode: isDarkMode,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildDialogTextField(
  //                   controller: remarkController,
  //                   label: 'Customer Remark',
  //                   icon: Icons.comment_rounded,
  //                   maxLines: 3,
  //                   theme: theme,
  //                   isDarkMode: isDarkMode,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildStatusDropdown(
  //                   value: status,
  //                   items: validStatuses,
  //                   theme: theme,
  //                   isDarkMode: isDarkMode,
  //                   onChanged: (value) {
  //                     if (value != null) status = value;
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               provider.updateFollowUp(
  //                 id: item.id,
  //                 companyName: companyController.text,
  //                 phone: phoneController.text,
  //                 date: dateController.text,
  //                 time: timeController.text,
  //                 remark: remarkController.text,
  //                 status: status,
  //               );
  //               Navigator.pop(context);
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: const Text('Follow-up updated successfully'),
  //                   backgroundColor: Colors.green,
  //                   behavior: SnackBarBehavior.floating,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //               );
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: theme.colorScheme.primary,
  //               foregroundColor: Colors.white,
  //             ),
  //             child: const Text('Update'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }


  void _showUpdateDialog(BuildContext context, FollowUpData item, FollowUpProvider provider) {
    final companyController = TextEditingController(text: item.companyName ?? '');
    final phoneController = TextEditingController(
      text: (item.person?.persons.isNotEmpty ?? false)
          ? item.person!.persons.first.phoneNumber ?? ''
          : '',
    );
    final dateController = TextEditingController(
      text: item.followDates.isNotEmpty
          ? item.followDates.first.split('T').first
          : '',
    );
    final timeController = TextEditingController(
      text: item.followTimes.isNotEmpty ? item.followTimes.first : '',
    );
    final remarkController = TextEditingController(text: item.action ?? '');
    final validStatuses = ['Complete', 'Hold', 'Close'];
    String status = item.status ?? 'Hold';

    if (status.isNotEmpty && !validStatuses.contains(status)) {
      validStatuses.add(status);
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Helper function to update date
            // Future<void> updateDate() async {
            //   DateTime? initialDate;
            //   if (dateController.text.isNotEmpty) {
            //     try {
            //       initialDate = DateTime.parse(dateController.text);
            //     } catch (e) {
            //       initialDate = DateTime.now();
            //     }
            //   } else {
            //     initialDate = DateTime.now();
            //   }
            //
            //   final picked = await showDatePicker(
            //     context: context,
            //     initialDate: initialDate!,
            //     firstDate: DateTime.now(),
            //     lastDate: DateTime(DateTime.now().year + 2),
            //   );
            //
            //   if (picked != null) {
            //     setState(() {
            //       dateController.text = DateFormat('yyyy-MM-dd').format(picked);
            //     });
            //   }
            // }


            Future<void> updateDate() async {
              DateTime? initialDate;
              if (dateController.text.isNotEmpty) {
                try {
                  initialDate = DateTime.parse(dateController.text);
                } catch (e) {
                  initialDate = DateTime.now();
                }
              } else {
                initialDate = DateTime.now();
              }

              // Determine the earliest allowable date
              // If existing date is in the past, allow it as firstDate
              final firstDate = initialDate!.isBefore(DateTime.now())
                  ? initialDate
                  : DateTime.now();

              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: firstDate, // Use calculated firstDate
                lastDate: DateTime(DateTime.now().year + 2),
              );

              if (picked != null) {
                setState(() {
                  dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                });
              }
            }

            // Helper function to update time
            Future<void> updateTime() async {
              TimeOfDay? initialTime;
              if (timeController.text.isNotEmpty) {
                try {
                  final timeParts = timeController.text.split(' ');
                  if (timeParts.length == 2) {
                    final hourMinute = timeParts[0].split(':');
                    final isPM = timeParts[1].toUpperCase() == 'PM';
                    if (hourMinute.length == 2) {
                      var hour = int.parse(hourMinute[0]);
                      final minute = int.parse(hourMinute[1]);

                      if (isPM && hour < 12) hour += 12;
                      if (!isPM && hour == 12) hour = 0;

                      initialTime = TimeOfDay(hour: hour, minute: minute);
                    }
                  }
                } catch (e) {
                  initialTime = TimeOfDay.now();
                }
              } else {
                initialTime = TimeOfDay.now();
              }

              final picked = await showTimePicker(
                context: context,
                initialTime: initialTime ?? TimeOfDay.now(),
              );

              if (picked != null) {
                setState(() {
                  timeController.text = picked.format(context);
                });
              }
            }



            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
              surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
              title: Text(
                'Update Follow-up',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogTextField(
                        controller: companyController,
                        label: 'Company Name',
                        icon: Icons.business_rounded,
                        theme: theme,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        theme: theme,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 12),

                      // Date field with onTap
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                          ),
                        ),
                        child: ListTile(
                          onTap: updateDate,
                          leading: Icon(
                            Icons.calendar_today_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            dateController.text.isEmpty
                                ? 'Next Follow-up Date'
                                : _formatDateForDisplay(dateController.text),
                            style: TextStyle(
                              color: dateController.text.isEmpty
                                  ? Colors.grey[500]
                                  : isDarkMode ? Colors.white : Colors.grey[800],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Time field with onTap
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                          ),
                        ),
                        child: ListTile(
                          onTap: updateTime,
                          leading: Icon(
                            Icons.access_time_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            timeController.text.isEmpty
                                ? 'Next Follow-up Time'
                                : timeController.text,
                            style: TextStyle(
                              color: timeController.text.isEmpty
                                  ? Colors.grey[500]
                                  : isDarkMode ? Colors.white : Colors.grey[800],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      _buildDialogTextField(
                        controller: remarkController,
                        label: 'Customer Remark',
                        icon: Icons.comment_rounded,
                        maxLines: 3,
                        theme: theme,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusDropdown(
                        value: status,
                        items: validStatuses,
                        theme: theme,
                        isDarkMode: isDarkMode,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              status = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.updateFollowUp(
                      id: item.id,
                      companyName: companyController.text,
                      phone: phoneController.text,
                      date: dateController.text,
                      time: timeController.text,
                      remark: remarkController.text,
                      status: status,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Follow-up updated successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDateForDisplay(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    required bool isDarkMode,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.grey[800],
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.grey[600],
            ),
            border: InputBorder.none,
            icon: Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildDatePickerField({
  //   required TextEditingController controller,
  //   required String label,
  //   required ThemeData theme,
  //   required BuildContext context,
  //   required bool isDarkMode,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
  //       ),
  //     ),
  //     child: ListTile(
  //       onTap: () async {
  //         final picked = await showDatePicker(
  //           context: context,
  //           initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
  //           firstDate: DateTime.now(),
  //           lastDate: DateTime(DateTime.now().year + 2),
  //           builder: (context, child) {
  //             return Theme(
  //               data: Theme.of(context).copyWith(
  //                 colorScheme: ColorScheme.light(
  //                   primary: theme.colorScheme.primary,
  //                   onPrimary: Colors.white,
  //                   surface: Colors.white,
  //                   onSurface: Colors.black,
  //                 ),
  //                 dialogBackgroundColor: Colors.white,
  //               ),
  //               child: child!,
  //             );
  //           },
  //         );
  //         if (picked != null) {
  //           controller.text = picked.toIso8601String().split('T').first;
  //         }
  //       },
  //       leading: Icon(
  //         Icons.calendar_today_rounded,
  //         color: theme.colorScheme.primary,
  //       ),
  //       title: Text(
  //         controller.text.isEmpty ? label : controller.text,
  //         style: TextStyle(
  //           color: controller.text.isEmpty
  //               ? Colors.grey[500]
  //               : isDarkMode ? Colors.white : Colors.grey[800],
  //         ),
  //       ),
  //       trailing: Icon(
  //         Icons.arrow_drop_down_rounded,
  //         color: theme.colorScheme.primary,
  //       ),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //     ),
  //   );
  // }



  Widget _buildDatePickerField({
    required String selectedDate,
    required String label,
    required ThemeData theme,
    required BuildContext context,
    required bool isDarkMode,
    required Function(String) onDateSelected,
  }) {
    // Helper function to format date for display
    String getDisplayText() {
      if (selectedDate.isEmpty) return label;

      try {
        // Try to parse as ISO date
        final date = DateTime.parse(selectedDate);
        return DateFormat('EEEE, MMMM d, yyyy').format(date);
      } catch (e) {
        // If not ISO format, return as-is
        return selectedDate;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: ListTile(
        onTap: () async {
          // Determine initial date
          DateTime? initialDate;
          if (selectedDate.isNotEmpty) {
            try {
              initialDate = DateTime.parse(selectedDate);
            } catch (e) {
              initialDate = DateTime.now();
            }
          } else {
            initialDate = DateTime.now();
          }

          final picked = await showDatePicker(
            context: context,
            initialDate: initialDate!,
            firstDate: DateTime.now(),
            lastDate: DateTime(DateTime.now().year + 2),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: theme.colorScheme.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            // Format date for API (yyyy-MM-dd)
            final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
            // Call the callback to update parent state
            onDateSelected(formattedDate);
          }
        },
        leading: Icon(
          Icons.calendar_today_rounded,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          getDisplayText(),
          style: TextStyle(
            color: selectedDate.isEmpty
                ? Colors.grey[500]
                : isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
        trailing: Icon(
          Icons.arrow_drop_down_rounded,
          color: theme.colorScheme.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTimePickerField({
    required String selectedTime,
    required String label,
    required ThemeData theme,
    required BuildContext context,
    required bool isDarkMode,
    required Function(String) onTimeSelected,
  }) {
    String getDisplayText() {
      return selectedTime.isEmpty ? label : selectedTime;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: ListTile(
        onTap: () async {
          TimeOfDay? initialTime;
          if (selectedTime.isNotEmpty) {
            try {
              // Parse time like "2:30 PM"
              final timeParts = selectedTime.split(' ');
              if (timeParts.length == 2) {
                final hourMinute = timeParts[0].split(':');
                final isPM = timeParts[1].toUpperCase() == 'PM';
                if (hourMinute.length == 2) {
                  var hour = int.parse(hourMinute[0]);
                  final minute = int.parse(hourMinute[1]);

                  if (isPM && hour < 12) hour += 12;
                  if (!isPM && hour == 12) hour = 0;

                  initialTime = TimeOfDay(hour: hour, minute: minute);
                }
              }
            } catch (e) {
              initialTime = TimeOfDay.now();
            }
          } else {
            initialTime = TimeOfDay.now();
          }

          final picked = await showTimePicker(
            context: context,
            initialTime: initialTime ?? TimeOfDay.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: theme.colorScheme.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            final formattedTime = picked.format(context);
            onTimeSelected(formattedTime);
          }
        },
        leading: Icon(
          Icons.access_time_rounded,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          getDisplayText(),
          style: TextStyle(
            color: selectedTime.isEmpty
                ? Colors.grey[500]
                : isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
        trailing: Icon(
          Icons.arrow_drop_down_rounded,
          color: theme.colorScheme.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Widget _buildTimePickerField({
  //   required TextEditingController controller,
  //   required String label,
  //   required ThemeData theme,
  //   required BuildContext context,
  //   required bool isDarkMode,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
  //       ),
  //     ),
  //     child: ListTile(
  //       onTap: () async {
  //         final picked = await showTimePicker(
  //           context: context,
  //           initialTime: TimeOfDay.now(),
  //           builder: (context, child) {
  //             return Theme(
  //               data: Theme.of(context).copyWith(
  //                 colorScheme: ColorScheme.light(
  //                   primary: theme.colorScheme.primary,
  //                   onPrimary: Colors.white,
  //                   surface: Colors.white,
  //                   onSurface: Colors.black,
  //                 ),
  //                 dialogBackgroundColor: Colors.white,
  //               ),
  //               child: child!,
  //             );
  //           },
  //         );
  //         if (picked != null) {
  //           controller.text = picked.format(context);
  //         }
  //       },
  //       leading: Icon(
  //         Icons.access_time_rounded,
  //         color: theme.colorScheme.primary,
  //       ),
  //       title: Text(
  //         controller.text.isEmpty ? label : controller.text,
  //         style: TextStyle(
  //           color: controller.text.isEmpty
  //               ? Colors.grey[500]
  //               : isDarkMode ? Colors.white : Colors.grey[800],
  //         ),
  //       ),
  //       trailing: Icon(
  //         Icons.arrow_drop_down_rounded,
  //         color: theme.colorScheme.primary,
  //       ),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildStatusDropdown({
  //   required String value,
  //   required List<String> items,
  //   required ThemeData theme,
  //   required bool isDarkMode,
  //   required Function(String?) onChanged,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
  //       ),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 12),
  //       child: DropdownButtonFormField<String>(
  //         value: value,
  //         decoration: InputDecoration(
  //           labelText: 'Status',
  //           labelStyle: TextStyle(
  //             color: Colors.grey[600],
  //           ),
  //           border: InputBorder.none,
  //           icon: Icon(
  //             Icons.edit,
  //             color: theme.colorScheme.primary,
  //           ),
  //         ),
  //         style: TextStyle(
  //           color: isDarkMode ? Colors.white : Colors.grey[800],
  //         ),
  //         dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
  //         items: items
  //             .map((s) => DropdownMenuItem(
  //           value: s,
  //           child: Row(
  //             children: [
  //               Icon(
  //                 _getStatusIcon(s),
  //                 size: 16,
  //                 color: _getStatusColor(s),
  //               ),
  //               const SizedBox(width: 8),
  //               Text(s),
  //             ],
  //           ),
  //         ))
  //             .toList(),
  //         onChanged: onChanged,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatusDropdown({
    required String value,
    required List<String> items,
    required ThemeData theme,
    required bool isDarkMode,
    required Function(String?) onChanged,
  }) {
    // Remove duplicates from items list
    final uniqueItems = items.toSet().toList();

    // Make sure the current value is in the list
    if (!uniqueItems.contains(value)) {
      uniqueItems.add(value);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: 'Status',
            labelStyle: TextStyle(
              color: Colors.grey[600],
            ),
            border: InputBorder.none,
            icon: Icon(
              Icons.edit,
              color: theme.colorScheme.primary,
            ),
          ),
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.grey[800],
          ),
          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
          items: uniqueItems
              .map((s) => DropdownMenuItem(
            value: s,
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(s),
                  size: 16,
                  color: _getStatusColor(s),
                ),
                const SizedBox(width: 8),
                Text(s),
              ],
            ),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }




  void _showDetailsDialog(BuildContext context, FollowUpData item) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final productName = item.product?.name ?? '-';
    final price = item.product?.price?.toString() ?? '-';
    final staffName = item.person?.assignedStaff?.username ?? 'Unassigned';
    final contactMethod = item.contactMethod ?? '-';
    final designation = item.designation ?? '-';
    final referToStaff = item.referToStaff ?? '-';
    final reference = item.reference ?? '-';
    final persons = item.person?.persons ?? [];
    final dates = item.followDates.join(', ');
    final times = item.followTimes.join(', ');
    final details = item.details.join('\n');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.business_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Follow-up Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('🏢 Company', item.companyName, theme),
                  _buildDetailItem('🧑‍💼 Staff', staffName, theme),
                  _buildDetailItem('📦 Product', productName, theme),
                  _buildDetailItem('💰 Price', price, theme),
                  _buildDetailItem('📞 Contact Method', contactMethod, theme),
                  _buildDetailItem('🎯 Status', item.status ?? '-', theme),
                  _buildDetailItem('📅 Follow Dates', dates, theme),
                  _buildDetailItem('⏰ Follow Times', times, theme),
                  _buildDetailItem('📝 Action', item.action ?? '-', theme),
                  if (details.isNotEmpty)
                    _buildDetailItem('📋 Details', details, theme),

                  const SizedBox(height: 16),
                  Text(
                    '👥 Contact Persons',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...persons.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                p.fullName ?? 'Unnamed',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(p.phoneNumber ?? '-'),
                            ],
                          ),
                          // if (p.email != null && p.email!.isNotEmpty) ...[
                          //   const SizedBox(height: 4),
                          //   Row(
                          //     children: [
                          //       Icon(
                          //         Icons.email_rounded,
                          //         size: 14,
                          //         color: Colors.grey[600],
                          //       ),
                          //       const SizedBox(width: 8),
                          //       Text(p.email!),
                          //     ],
                          //   ),
                          // ],
                        ],
                      ),
                    ),
                  )),

                  if (persons.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No person details available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),

                  const SizedBox(height: 16),
                  _buildDetailItem('🏷️ Designation', designation, theme),
                  _buildDetailItem('🔗 Reference', reference, theme),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}