import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../../View/staff/staff_form_dialog.dart';
import '../../constants/api_config.dart';
import '../../model/staff_model/staffModel.dart' hide Image;
import '../../compoents/premium_header.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final acp = Provider.of<AccessControlProvider>(context);
    
    final canRead = acp.canRead(PermissionKeys.employee);
    final canCreate = acp.canCreate(PermissionKeys.employee);
    final canUpdate = acp.canUpdate(PermissionKeys.employee);

    if (!canRead) {
      return Center(
        child: AnimationConfiguration.synchronized(
          child: FadeInAnimation(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.shield_cross, size: 80, color: Colors.red.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                const Text("Access Denied", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("You don't have permission to view staff.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
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
                  AppTheme.showAnimatedDialog(
                    context: context,
                    child: const StaffFormDialog(),
                  );
                }
              },
              hintText: "Search staff members...",
              showAdd: canCreate,
            ),
            // Filter Chips Row
            if (staffProvider.staffs.isNotEmpty)
              AnimationConfiguration.synchronized(
                child: FadeInAnimation(
                  child: Container(
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
                            backgroundColor: Colors.white,
                            selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: isSelected ? const BorderSide(color: AppTheme.primaryColor, width: 1.5) : BorderSide.none,
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: staffProvider.isLoading
                  ? _buildShimmerLoading()
                  : filteredStaffs.isEmpty
                      ? _buildEmptyState(context, _searchQuery, _searchController, canCreate)
                      : AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredStaffs.length,
                            itemBuilder: (context, index) {
                              final staff = filteredStaffs[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: _buildStaffCard(context, staff, index, canUpdate),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffData staff, int index, bool canUpdate) {
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
            AppTheme.showAnimatedDialog(
              context: context,
              child: StaffFormDialog(staff: staff),
            );
          }
        },
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _getAvatarColor(index).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getAvatarColor(index).withValues(alpha: 0.5), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildStaffAvatar(staff, initials, Theme.of(context), index),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      staff.designation ?? staff.department ?? 'No Designation',
                      style: TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Iconsax.sms, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 8),
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
                      ),
                      // const SizedBox(width: 8),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      //   decoration: BoxDecoration(
                      //     color: Colors.blue.withValues(alpha: 0.1),
                      //     borderRadius: BorderRadius.circular(6),
                      //   ),
                      //   child: Text(
                      //     staff.dutyShift ?? 'General',
                      //     style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Row(
                  //   children: [
                  //     Icon(Iconsax.location, size: 14, color: Colors.grey.shade400),
                  //     const SizedBox(width: 8),
                  //     Text(
                  //       staff.city ?? 'No City',
                  //       style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  //     ),
                  //     const Spacer(),
                  //     // Text(
                  //     //   staff.mobile?.isNotEmpty == true ? staff.mobile! : (staff.phone ?? ''),
                  //     //   style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                  //     // ),
                  //   ],
                  // ),
                ],
              ),
            ),
            // if (canUpdate)
            //   Icon(Iconsax.edit_2, color: Colors.grey.withValues(alpha: 0.5), size: 20),
          ],
        ),
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
            Iconsax.user_remove,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'No Staff Members Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white54 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              searchQuery.isNotEmpty
                  ? 'No staff members match your search query.'
                  : 'Add your first staff member to begin managing your team.',
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
              icon: const Icon(Iconsax.refresh),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                foregroundColor: isDarkMode ? Colors.white : Colors.grey[800],
              ),
            )
          else if (canCreate)
            ElevatedButton.icon(
              onPressed: () {
                AppTheme.showAnimatedDialog(
                  context: context,
                  child: const StaffFormDialog(),
                );
              },
              icon: const Icon(Iconsax.user_add),
              label: const Text('Add Staff Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStaffAvatar(StaffData staff, String initials, ThemeData theme, int index) {
    final imageUrl = staff.profileImage;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: _getAvatarColor(index),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );
    }

    return Image.network(
      ApiConfig.getImageUrl(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: _getAvatarColor(index),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
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
            color: AppTheme.primaryColor,
          ),
        );
      },
    );
  }

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
