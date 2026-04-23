import 'package:flutter/material.dart';
import 'package:infinity/View/staff/staff_form_dialog.dart';
import 'package:infinity/constants/api_config.dart';
import 'package:infinity/model/staff_model/staffModel.dart' hide Image;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../compoents/premium_header.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import '../../Provider/staff/StaffProvider.dart';
import '../../Provider/auth/access_control_provider.dart';
import '../../constants/permission_keys.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    Future.microtask(() =>
        Provider.of<StaffProvider>(context, listen: false).fetchStaff());
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StaffData> _filteredStaffs(StaffProvider provider) {
    var filtered = provider.staffs;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((staff) {
        final name = staff.employeeName?.toLowerCase() ?? '';
        final email = staff.email?.toLowerCase() ?? '';
        final department = staff.department?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            email.contains(query) ||
            department.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((staff) {
        return staff.department == _selectedFilter;
      }).toList();
    }

    return filtered;
  }

  List<String> _availableDepartments(StaffProvider provider) {
    final departments = provider.staffs
        .map((staff) => staff.department)
        .where((dept) => dept != null && dept.isNotEmpty)
        .toSet()
        .toList()
        .cast<String>();

    return ['All', ...departments];
  }

  void _showDeleteDialog(BuildContext context, String staffId, String staffName) {
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
          'Delete Staff Member',
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
              'Are you sure you want to delete "$staffName"?',
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
              Provider.of<StaffProvider>(context, listen: false)
                  .DeleteStaff(staffId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Staff deleted successfully'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final acp = Provider.of<AccessControlProvider>(context);
    
    final canRead = acp.canRead(PermissionKeys.employee);
    final canCreate = acp.canCreate(PermissionKeys.employee);
    final canUpdate = acp.canUpdate(PermissionKeys.employee);

    if (!canRead) {
      return const Center(
        child: Text(
          "You don't have permission to view staff.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return Consumer<StaffProvider>(
      builder: (context, staffProvider, child) {
        final filteredStaffs = _filteredStaffs(staffProvider);

        return Column(
          children: [
            PremiumActionHeader(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              onAddTap: () {
                if (canCreate) {
                  showDialog(
                    context: context,
                    builder: (context) => const StaffFormDialog(),
                  );
                }
              },
              hintText: "Search staff members...",
              showAdd: canCreate,
            ),
            // Filter Chips Row
            if (staffProvider.staffs.isNotEmpty)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _availableDepartments(staffProvider).map((dept) {
                    final isSelected = _selectedFilter == dept;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(dept),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedFilter = selected ? dept : 'All');
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
              child: staffProvider.isLoading
                  ? _buildShimmerLoading()
                  : filteredStaffs.isEmpty
                      ? _buildEmptyState(context, _searchQuery, _searchController, canCreate)
                      : _buildStaffList(context, filteredStaffs, canUpdate),
            ),
          ],
        );
      },
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
            height: 100,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchQuery, TextEditingController searchController, bool canCreate) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_alt_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Staff Members Found',
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
                  ? 'No staff members match your search'
                  : 'Add your first staff member to get started',
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
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                foregroundColor: isDarkMode ? Colors.white : Colors.grey[800],
              ),
            )
          else if (canCreate)
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const StaffFormDialog(),
                );
              },
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add Staff Member'),
            ),
        ],
      ),
    );
  }

  Widget _buildStaffList(BuildContext context, List<StaffData> staffs, bool canUpdate) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: staffs.length,
      itemBuilder: (context, index) {
        final staff = staffs[index];
        final initials = staff.employeeName
                ?.split(' ')
                .map((word) => word.isNotEmpty ? word[0] : '')
                .take(2)
                .join()
                .toUpperCase() ??
            '?';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PremiumCard(
            padding: const EdgeInsets.all(16),
            onTap: () {
              if (canUpdate) {
                showDialog(
                  context: context,
                  builder: (context) => StaffFormDialog(staff: staff),
                );
              }
            },
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getAvatarColor(index).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: _buildStaffAvatar(staff, initials, Theme.of(context)),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.employeeName ?? 'Unknown',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.designation ?? staff.department ?? 'No Designation',
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Iconsax.sms, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              staff.email ?? 'No email',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaffAvatar(StaffData staff, String initials, ThemeData theme) {
    final imageUrl = staff.profileImage;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }

    return Image.network(
      ApiConfig.getImageUrl(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            color: Colors.white,
          ),
        );
      },
    );
  }

  // void _showDeleteDialog(BuildContext context, String staffId, String staffName) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Delete Staff'),
  //       content: Text('Are you sure you want to delete $staffName?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Provider.of<StaffProvider>(context, listen: false).DeleteStaff(staffId);
  //             Navigator.pop(context);
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(content: Text('Staff deleted successfully')),
  //             );
  //           },
  //           child: const Text('Delete', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF5B86E5),
      const Color(0xFF36D1DC),
      const Color(0xFFF45C43),
      const Color(0xFF6A11CB),
      const Color(0xFF2575FC),
      const Color(0xFF2AF598),
      const Color(0xFFF093FB),
      const Color(0xFF667EEA),
    ];
    return colors[index % colors.length];
  }
}
