import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../Provider/CustomersTrackProvider/MeetingTrackProvider.dart';
import '../../Provider/product/product_provider.dart';
import '../../Provider/staff/StaffProvider.dart';
import '../../compoents/responsive_helper.dart';

class MeetingTrackScreen extends StatefulWidget {
  const MeetingTrackScreen({super.key});

  @override
  State<MeetingTrackScreen> createState() => _MeetingTrackScreenState();
}

class _MeetingTrackScreenState extends State<MeetingTrackScreen> {
  final List<String> dateOptions = ['today', '1week', '14days', 'all'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  String _selectedFilter = 'All';
  List<String> _filters = ['All', 'Hold', 'Follow Up', 'Completed'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StaffProvider>(context, listen: false).fetchStaff();
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<MeetingTrackProvider>(context, listen: false).fetchMeetings();
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
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

  void _scrollListener() {
    // Handle scroll for pagination if needed
  }

  void _refreshMeetings() {
    Provider.of<MeetingTrackProvider>(context, listen: false).fetchMeetings();
  }

  List<dynamic> _getFilteredMeetings(MeetingTrackProvider provider) {
    var filtered = provider.filteredMeetings;

    // Apply local search filter if any
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((meeting) {
        final companyName = meeting.companyName?.toLowerCase() ?? '';
        final persons = meeting.persons
            ?.map((p) => p.fullName?.toLowerCase() ?? '')
            .join(' ') ??
            '';
        final staffName = meeting.assignedStaff?.username?.toLowerCase() ?? '';
        final productName = meeting.assignedProducts?.name?.toLowerCase() ?? '';
        final status = meeting.status?.toLowerCase() ?? '';

        return companyName.contains(query) ||
            persons.contains(query) ||
            staffName.contains(query) ||
            productName.contains(query) ||
            status.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((meeting) {
        final timeline = meeting.timeline?.toLowerCase() ?? '';
        final status = meeting.status?.toLowerCase() ?? '';
        return timeline.contains(_selectedFilter.toLowerCase()) ||
            status.contains(_selectedFilter.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'hold':
      case 'pending':
        return Colors.orange;
      case 'follow up':
      case 'scheduled':
        return Colors.blue;
      case 'completed':
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    if (status == null) return Icons.info_outline_rounded;
    switch (status.toLowerCase()) {
      case 'hold':
      case 'pending':
        return Icons.pause_circle_filled_rounded;
      case 'follow up':
      case 'scheduled':
        return Icons.update_rounded;
      case 'completed':
      case 'done':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getTimelineColor(String? timeline) {
    if (timeline == null) return Colors.grey;
    switch (timeline.toLowerCase()) {
      case 'follow up':
        return Colors.blue;
      case 'not interested':
        return Colors.red;
      case 'already installed':
        return Colors.green;
      case 'phone responded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<MeetingTrackProvider>(
        builder: (context, provider, _) {
          final filteredMeetings = _getFilteredMeetings(provider);
          final totalPages = (filteredMeetings.length / _itemsPerPage).ceil();
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = startIndex + _itemsPerPage > filteredMeetings.length
              ? filteredMeetings.length
              : startIndex + _itemsPerPage;
          final paginatedList = filteredMeetings.sublist(startIndex, endIndex);

          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  expandedHeight: context.sh(0.18),
                  elevation: 4,
                  backgroundColor: theme.appBarTheme.backgroundColor,
                  surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  actions: [
                    IconButton(
                      onPressed: _refreshMeetings,
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh',
                    ),
                  ],
                  title: Text(
                    'Meeting Tracking',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(context.sh(0.15)),
                    child: Container(
                      color: theme.appBarTheme.backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          children: [
                            // Search Bar
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.search_rounded,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      style: const TextStyle(fontSize: 15),
                                      decoration: InputDecoration(
                                        hintText: 'Search meetings...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[500],
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty)
                                    IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Status Filter Chips
                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _filters.map((filter) {
                                  final isSelected = _selectedFilter == filter;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(
                                        filter,
                                        style: TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() => _selectedFilter = selected ? filter : 'All');
                                      },
                                      backgroundColor: isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[100],
                                      selectedColor: theme.colorScheme.primary
                                          .withOpacity(0.2),
                                      checkmarkColor: theme.colorScheme.primary,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.grey[700],
                                        fontWeight:
                                        isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : Colors.transparent,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: provider.isLoading
                ? _buildShimmerLoading()
                : provider.filteredMeetings.isEmpty
                ? _buildEmptyState(context, _searchQuery, _searchController)
                : _buildMeetingList(context, paginatedList, totalPages, theme, isDarkMode, provider),
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

  Widget _buildEmptyState(BuildContext context, String searchQuery, TextEditingController searchController) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            searchQuery.isNotEmpty ? 'No Meetings Found' : 'No Meetings',
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
                  ? 'No meetings match your search criteria'
                  : 'No meetings found with the current filters',
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

  Widget _buildMeetingList(
      BuildContext context,
      List<dynamic> meetings,
      int totalPages,
      ThemeData theme,
      bool isDarkMode,
      MeetingTrackProvider provider,
      ) {
    return Column(
      children: [
        // Filter Controls Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Material(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Staff Filter
                  Consumer<StaffProvider>(
                    builder: (context, staffProvider, _) {
                      return _buildFilterDropdown(
                        label: 'Assigned Staff',
                        icon: Icons.person_rounded,
                        value: provider.selectedStaffName,
                        items: [
                          _buildDropdownItem('All Staff', null, Icons.group_rounded),
                          ...staffProvider.staffs.map((staff) =>
                              _buildDropdownItem(
                                  staff.username ?? 'Unnamed Staff',
                                  staff.username,
                                  Icons.person_outline_rounded
                              )
                          ),
                        ],
                        onChanged: (value) {
                          provider.setStaff(value == null ? null : '', value);
                        },
                        theme: theme,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Product Filter
                  Consumer<ProductProvider>(
                    builder: (context, productProvider, _) {
                      return _buildFilterDropdown(
                        label: 'Assigned Product',
                        icon: Icons.inventory_2_rounded,
                        value: provider.selectedProductName,
                        items: [
                          _buildDropdownItem('All Products', null, Icons.category_rounded),
                          ...productProvider.products.map((product) =>
                              _buildDropdownItem(
                                  product.name ?? 'Unnamed Product',
                                  product.name,
                                  Icons.shopping_bag_outlined
                              )
                          ),
                        ],
                        onChanged: (value) {
                          provider.setProduct(value == null ? null : '', value);
                        },
                        theme: theme,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date Range Filter
                  _buildFilterDropdown(
                    label: 'Date Range',
                    icon: Icons.calendar_today_rounded,
                    value: provider.selectedDateRange,
                    items: dateOptions.map((option) =>
                        _buildDropdownItem(
                            option.toUpperCase(),
                            option,
                            _getDateRangeIcon(option)
                        )
                    ).toList(),
                    onChanged: provider.setDateRange,
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Results Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${meetings.length} Meeting${meetings.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Meeting List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              final status = meeting.status ?? 'No Status';
              final timeline = meeting.timeline ?? 'No Timeline';
              final statusColor = _getStatusColor(status);
              final statusIcon = _getStatusIcon(status);
              final timelineColor = _getTimelineColor(timeline);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with company name and status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                meeting.companyName ?? 'Unknown Company',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Status Badge
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
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Timeline Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: timelineColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: timelineColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    timeline,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: timelineColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Contact Persons
                        if (meeting.persons?.isNotEmpty ?? false)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                icon: Icons.people_rounded,
                                label: 'Contact Persons',
                                value: meeting.persons!
                                    .map((p) => p.fullName ?? 'Unnamed')
                                    .join(', '),
                                theme: theme,
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),

                        // Assigned Staff
                        if (meeting.assignedStaff?.username != null)
                          _buildDetailRow(
                            icon: Icons.person_rounded,
                            label: 'Assigned Staff',
                            value: meeting.assignedStaff!.username!,
                            theme: theme,
                            isDarkMode: isDarkMode,
                          ),
                        const SizedBox(height: 8),

                        // Assigned Product
                        if (meeting.assignedProducts?.name != null)
                          _buildDetailRow(
                            icon: Icons.shopping_bag_rounded,
                            label: 'Product',
                            value: meeting.assignedProducts!.name!,
                            theme: theme,
                            isDarkMode: isDarkMode,
                          ),

                        // Additional details can be added here
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
              color: theme.cardColor,
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
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String?>> items,
    required Function(String?) onChanged,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String?>(
          value: value,
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
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.grey[800],
          ),
          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  DropdownMenuItem<String?> _buildDropdownItem(String text, String? value, IconData icon) {
    return DropdownMenuItem<String?>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  IconData _getDateRangeIcon(String range) {
    switch (range) {
      case 'today':
        return Icons.today_rounded;
      case '1week':
        return Icons.date_range_rounded;
      case '14days':
        return Icons.calendar_view_week_rounded;
      case 'all':
        return Icons.all_inclusive_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
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
          color: Colors.grey[500],
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
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}