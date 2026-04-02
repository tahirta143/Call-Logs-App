import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../compoents/premium_header.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import '../../Provider/customer/customer_provider.dart';
import 'add_customer.dart';
import 'customer detail.dart';
import 'customerUpdate.dart';
import '../../compoents/responsive_helper.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  String? userRole;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _showFloatingButton = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompanyProvider>(context, listen: false).fetchCompanies();
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
      if (_showFloatingButton) setState(() => _showFloatingButton = false);
    } else {
      if (!_showFloatingButton) setState(() => _showFloatingButton = true);
    }
  }

  List<String> _getBusinessTypes(CompanyProvider provider) {
    final types = provider.companies
        .map((c) => c.businessType)
        .where((type) => type != null && type.isNotEmpty)
        .toSet()
        .toList()
        .cast<String>();
    return ['All', ...types];
  }

  List<dynamic> _getFilteredCompanies(CompanyProvider provider) {
    var filtered = provider.companies;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((company) {
        final name = company.companyName.toLowerCase();
        final city = company.city?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || city.contains(query);
      }).toList();
    }
    if (_selectedFilter != 'All') {
      filtered = filtered.where((company) {
        return company.businessType == _selectedFilter;
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<CompanyProvider>(
        builder: (context, provider, child) {
          final filteredCompanies = _getFilteredCompanies(provider);
          final totalPages = (filteredCompanies.length / _itemsPerPage).ceil();
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = startIndex + _itemsPerPage > filteredCompanies.length
              ? filteredCompanies.length
              : startIndex + _itemsPerPage;
          final paginatedList = filteredCompanies.sublist(startIndex, endIndex);

          return Column(
            children: [
              PremiumActionHeader(
                controller: _searchController,
                showAdd: userRole == 'admin',
                hintText: "Search companies...",
                onChanged: (value) => setState(() => _searchQuery = value),
                onAddTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
                ),
              ),
              if (provider.companies.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: _getBusinessTypes(provider).map((type) {
                      final isSelected = _selectedFilter == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedFilter = type);
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
                    : filteredCompanies.isEmpty
                        ? _buildEmptyState(context, _searchQuery, _searchController)
                        : _buildCompanyList(paginatedList, totalPages, theme, isDarkMode),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompanyList(List<dynamic> companies, int totalPages, ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PremiumCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CompanyDetailScreen(company: company)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getCompanyColor(index),
                                _getCompanyColor(index).withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Iconsax.box, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                company.companyName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Iconsax.location, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    company.city ?? "N/A",
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (userRole == 'admin')
                          IconButton(
                            icon: const Icon(Iconsax.edit, color: AppTheme.primaryColor, size: 20),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpdateCustomerScreen(customerId: company.sId)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (totalPages > 1) _buildPagination(totalPages, theme, isDarkMode),
      ],
    );
  }

  Widget _buildPagination(int totalPages, ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: isDarkMode ? Colors.white10 : Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            icon: const Icon(Iconsax.arrow_left_2, size: 16),
            label: const Text("Prev"),
          ),
          Text(
            "Page ${_currentPage + 1} of $totalPages",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          OutlinedButton.icon(
            onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
            icon: const Icon(Iconsax.arrow_right_3, size: 16),
            label: const Text("Next"),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchQuery, TextEditingController searchController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.receipt_search, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty ? "No results found" : "No companies added",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Text("Clear search"),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCompanyColor(int index) {
    final colors = [
      const Color(0xFF5B86E5),
      const Color(0xFF36D1DC),
      const Color(0xFFF45C43),
      const Color(0xFF6A11CB),
      const Color(0xFF2575FC),
      const Color(0xFF2AF598),
    ];
    return colors[index % colors.length];
  }
}