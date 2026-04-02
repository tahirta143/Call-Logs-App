import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../Provider/CustomersTrackProvider/CustomerTrackProvider.dart';
import '../../Provider/product/product_provider.dart';
import '../../Provider/staff/StaffProvider.dart';
import '../../compoents/responsive_helper.dart';

class CustomersTrackScreen extends StatefulWidget {
  const CustomersTrackScreen({super.key});

  @override
  State<CustomersTrackScreen> createState() => _CustomersTrackScreenState();
}

class _CustomersTrackScreenState extends State<CustomersTrackScreen> {
  final List<String> dateOptions = ['today', '1week', '14days', 'all'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StaffProvider>(context, listen: false).fetchStaff();
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<CustomersTrackProvider>(context, listen: false)
          .fetchCustomers();
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

  void _refreshCustomers() {
    Provider.of<CustomersTrackProvider>(context, listen: false)
        .fetchCustomers();
  }

  List<dynamic> _getFilteredCustomers(CustomersTrackProvider provider) {
    var filtered = provider.filteredCustomers;

    // Apply local search filter if any
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((customer) {
        final company = customer.company?.toLowerCase() ?? '';
        final city = customer.city?.toLowerCase() ?? '';
        final staff = customer.staff?.toLowerCase() ?? '';
        final product = customer.product?.toLowerCase() ?? '';

        return company.contains(query) ||
            city.contains(query) ||
            staff.contains(query) ||
            product.contains(query);
      }).toList();
    }

    return filtered;
  }

  Color _getDateIndicatorColor(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) return Colors.red; // Past
    if (difference == 0) return Colors.orange; // Today
    if (difference <= 7) return Colors.blue; // This week
    return Colors.green; // Future
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<CustomersTrackProvider>(
        builder: (context, provider, _) {
          final filteredCustomers = _getFilteredCustomers(provider);
          final totalPages = (filteredCustomers.length / _itemsPerPage).ceil();
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = startIndex + _itemsPerPage > filteredCustomers.length
              ? filteredCustomers.length
              : startIndex + _itemsPerPage;
          final paginatedList = filteredCustomers.sublist(startIndex, endIndex);

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
                      onPressed: _refreshCustomers,
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh',
                    ),
                  ],
                  title: Text(
                    'Customer Tracking',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(context.sh(0.08)),
                    child: Container(
                      color: theme.appBarTheme.backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Container(
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
                                    hintText: 'Search customers...',
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
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: provider.isLoading
                ? _buildShimmerLoading()
                : provider.filteredCustomers.isEmpty
                ? _buildEmptyState(context, _searchQuery, _searchController)
                : _buildCustomerList(context, paginatedList, totalPages, theme, isDarkMode),
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
            height: 120,
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
            Icons.group_remove_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            searchQuery.isNotEmpty ? 'No Customers Found' : 'No Customers',
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
                  ? 'No customers match your search'
                  : 'No customers found with the current filters',
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

  Widget _buildCustomerList(
      BuildContext context,
      List<dynamic> customers,
      int totalPages,
      ThemeData theme,
      bool isDarkMode,
      ) {
    final provider = Provider.of<CustomersTrackProvider>(context, listen: false);

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
                  '${customers.length} Customer${customers.length != 1 ? 's' : ''}',
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

        // Customer List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              final date = customer.date ?? DateTime.now();
              final dateColor = _getDateIndicatorColor(date);

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
                        // Header with company and date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                customer.company ?? 'Unknown Company',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
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
                                color: dateColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: dateColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: dateColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('MMM dd').format(date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: dateColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // City
                        _buildDetailRow(
                          icon: Icons.location_on_rounded,
                          label: 'City',
                          value: customer.city ?? 'N/A',
                          theme: theme,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 8),

                        // Staff
                        _buildDetailRow(
                          icon: Icons.person_rounded,
                          label: 'Assigned Staff',
                          value: customer.staff ?? 'N/A',
                          theme: theme,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 8),

                        // Product
                        _buildDetailRow(
                          icon: Icons.shopping_bag_rounded,
                          label: 'Product',
                          value: customer.product ?? 'N/A',
                          theme: theme,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 8),

                        // Full Date
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Registered Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('EEEE, MMMM d, yyyy').format(date),
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