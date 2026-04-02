import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../Provider/AssignCustomerProvider/AssignProvider.dart';
import '../../Provider/product/product_provider.dart';
import '../../Provider/staff/StaffProvider.dart';
import '../../compoents/responsive_helper.dart';
import '../../compoents/premium_header.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class UnassignCustomerScreen extends StatefulWidget {
  const UnassignCustomerScreen({super.key});

  @override
  State<UnassignCustomerScreen> createState() => _UnassignCustomerScreenState();
}

class _UnassignCustomerScreenState extends State<UnassignCustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UnassignCustomerProvider>(context, listen: false)
            .fetchUnassignedCustomers());
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshCustomers() {
    Provider.of<UnassignCustomerProvider>(context, listen: false)
        .fetchUnassignedCustomers();
  }

  Future<void> _showAssignDialog(BuildContext context) async {
    final assignProvider =
    Provider.of<UnassignCustomerProvider>(context, listen: false);
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    await Future.wait([
      staffProvider.fetchStaff(),
      productProvider.fetchProducts(),
    ]);

    String? selectedStaff;
    String? selectedProduct;

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
          title: Text(
            'Assign Staff & Product',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Staff Dropdown
                Consumer<StaffProvider>(
                  builder: (context, staffProv, _) {
                    if (staffProv.isLoading) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
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
                          decoration: InputDecoration(
                            labelText: 'Select Staff',
                            labelStyle: TextStyle(
                              color: Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.person_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          value: selectedStaff,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.grey[800],
                          ),
                          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                          items: staffProv.staffs.map((staff) {
                            return DropdownMenuItem<String>(
                              value: staff.sId,
                              child: Text(staff.username ?? 'Unnamed Staff'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedStaff = value;
                          },
                          validator: (value) => value == null
                              ? 'Please select a staff member'
                              : null,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Product Dropdown
                Consumer<ProductProvider>(
                  builder: (context, productProv, _) {
                    if (productProv.isLoading) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
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
                          decoration: InputDecoration(
                            labelText: 'Select Product',
                            labelStyle: TextStyle(
                              color: Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.inventory_2_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          value: selectedProduct,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.grey[800],
                          ),
                          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                          items: productProv.products.map((product) {
                            return DropdownMenuItem<String>(
                              value: product.sId,
                              child: Text(product.name ?? 'Unnamed Product'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedProduct = value;
                          },
                          validator: (value) =>
                          value == null ? 'Please select a product' : null,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStaff == null || selectedProduct == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please select both fields'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await assignProvider.assignSelectedCustomers(
                    staffId: selectedStaff!,
                    productId: selectedProduct!,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Customers assigned successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to assign: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Consumer<UnassignCustomerProvider>(
          builder: (context, provider, _) => Text(
            provider.selectedIds.isEmpty
                ? 'Unassigned Customers'
                : 'Selected: ${provider.selectedIds.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshCustomers,
            icon: const Icon(Iconsax.refresh),
            tooltip: 'Refresh',
          ),
          Consumer<UnassignCustomerProvider>(
            builder: (context, provider, _) {
              if (provider.selectedIds.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: () => _showAssignDialog(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.user_add,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  tooltip: 'Assign Selected',
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<UnassignCustomerProvider>(
        builder: (context, provider, child) {
          final filteredCustomers = _searchQuery.isEmpty
              ? provider.customers
              : provider.customers.where((customer) {
            final companyName = customer.companyName?.toLowerCase() ?? '';
            final businessType = customer.businessType?.toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return companyName.contains(query) || businessType.contains(query);
          }).toList();

          return Column(
            children: [
              PremiumActionHeader(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                onAddTap: () {}, // Not used here
                showAdd: false,
                hintText: "Search unassigned customers...",
              ),
              Expanded(
                child: provider.isLoading
                    ? _buildShimmerLoading()
                    : provider.errorMessage != null
                    ? _buildErrorState(provider.errorMessage!, theme, isDarkMode)
                    : filteredCustomers.isEmpty
                    ? _buildEmptyState(context, _searchQuery, _searchController)
                    : _buildCustomerList(context, filteredCustomers, provider, theme, isDarkMode),
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
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 100,
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
            'Error Loading Customers',
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
              Provider.of<UnassignCustomerProvider>(context, listen: false)
                  .fetchUnassignedCustomers();
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
            Icons.group_remove_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            searchQuery.isNotEmpty ? 'No Customers Found' : 'No Unassigned Customers',
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
                  ? 'No unassigned customers match your search'
                  : 'All customers have been assigned to staff',
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
      UnassignCustomerProvider provider,
      ThemeData theme,
      bool isDarkMode,
      ) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final person = (customer.persons?.isNotEmpty ?? false)
            ? customer.persons!.first.fullName ?? 'N/A'
            : 'N/A';
        final phone = (customer.persons?.isNotEmpty ?? false)
            ? customer.persons!.first.phoneNumber ?? 'N/A'
            : 'N/A';
        final isSelected = provider.selectedIds.contains(customer.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PremiumCard(
            onTap: () {
              provider.toggleSelection(customer.id!);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => provider.toggleSelection(customer.id!),
                      activeColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Customer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.companyName ?? 'Unknown Company',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                customer.businessType ?? '-',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Contact Person
                        _buildInfoRow(
                          icon: Iconsax.user,
                          label: 'Contact Person',
                          value: person,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 8),

                        // Phone Number
                        _buildInfoRow(
                          icon: Iconsax.call,
                          label: 'Phone Number',
                          value: phone,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
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
}
