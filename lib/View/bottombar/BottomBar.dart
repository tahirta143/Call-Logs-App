import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Provider/theme_provider.dart';
import '../../compoents/responsive_helper.dart';
import '../Meeting_calender/AllMeeting.dart';
import '../followUpScreen/FollowUpScreen.dart';
import '../AssignScreen/AssignCustomer.dart';
import '../call_logs_track/call_logs_track.dart';
import '../SuccessClientScreen/successClientProvider.dart';
import '../Meeting_calender/MeetingCalender.dart';
import '../Activity_Track/Activity_Track_Screen.dart';
import '../Auths/Login_screen.dart';

import '../Customer/customer_list.dart';
import '../home/dashboard_screen.dart';
import '../products/product_screen.dart';
import '../staff/staffListScreen.dart';

class BottombarScreen extends StatefulWidget {
  const BottombarScreen({super.key});

  @override
  State<BottombarScreen> createState() => _BottombarScreenState();
}

class _BottombarScreenState extends State<BottombarScreen> {
  int _selectedIndex = 0;
  String? userRole;
  List<Widget> _screens = [];
  
  // For sub-screen navigation support
  Widget? _subScreenBody;
  String? _subScreenTitle;

  // Admin tabs config
  final List<_NavItem> _adminItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.shopping_bag_rounded, label: 'Product'),
    _NavItem(icon: Icons.people_rounded, label: 'Staff'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Customer'),
  ];

  // Non-admin tabs config
  final List<_NavItem> _staffItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Customer'),
  ];

  List<_NavItem> get _currentItems =>
      userRole == 'admin' ? _adminItems : _staffItems;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    setState(() {
      userRole = role;
      if (role == 'admin') {
        _screens = const [
          DashboardScreen(),
          ProductScreen(),
          StaffScreen(),
          CompanyListScreen(),
        ];
      } else {
        _screens = const [
          DashboardScreen(),
          CompanyListScreen(),
        ];
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _subScreenBody = null;
      _subScreenTitle = null;
    });
  }

  void navigateToSubScreen(Widget screen, String title) {
    setState(() {
      _subScreenBody = screen;
      _subScreenTitle = title;
    });
  }

  String _getAppBarTitle() {
    if (_subScreenTitle != null) return _subScreenTitle!;
    final items = _currentItems;
    if (_selectedIndex >= 0 && _selectedIndex < items.length) {
      return items[_selectedIndex].label;
    }
    return 'Infinity';
  }

  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> _confirmLogout() async {
    Navigator.pop(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(
            _getAppBarTitle(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(isDark ? Iconsax.sun_1 : Iconsax.moon),
              onPressed: () => themeProvider.toggleTheme(!isDark),
            ),
          ],
        ),
        drawer: _buildDrawer(theme),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 90),
          child: _subScreenBody ?? _screens[_selectedIndex],
        ),
        bottomNavigationBar: _buildCardBottomNav(isDark),
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      width: context.sw(0.78),
      backgroundColor: theme.drawerTheme.backgroundColor,
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
            ),
            child: FutureBuilder<String?>(
              future: _getUsername(),
              builder: (context, snapshot) {
                final username = snapshot.data ?? "User";
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: Icon(
                          Iconsax.profile_circle,
                          color: theme.colorScheme.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome,',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              children: [
                _buildDrawerItem(
                  icon: Iconsax.home,
                  label: 'Dashboard',
                  onTap: () {
                    _onItemTapped(0);
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Iconsax.calendar_2,
                  label: 'All Meeting Details',
                  onTap: () {
                    Navigator.pop(context);
                    navigateToSubScreen(const NoDateMeetingScreen(), 'Meetings');
                  },
                ),
                _buildDrawerItem(
                  icon: Iconsax.refresh_circle,
                  label: 'Follow Up',
                  onTap: () {
                    Navigator.pop(context);
                    navigateToSubScreen(const FollowUpScreen(), 'Follow Up');
                  },
                ),
                if (userRole == 'admin')
                  _buildDrawerItem(
                    icon: Iconsax.user_add,
                    label: 'Assign To',
                    onTap: () {
                      Navigator.pop(context);
                      navigateToSubScreen(const UnassignCustomerScreen(), 'Assign Customers');
                    },
                  ),
                if (userRole == 'admin')
                  _buildDrawerItem(
                    icon: Iconsax.call,
                    label: 'Call Track',
                    onTap: () {
                      Navigator.pop(context);
                      navigateToSubScreen(const CallLogsScreen(), 'Call Tracker');
                    },
                  ),
                _buildDrawerItem(
                  icon: Iconsax.like_1,
                  label: 'Success Client',
                  onTap: () {
                    Navigator.pop(context);
                    navigateToSubScreen(const SuccessClientScreen(), 'Success Clients');
                  },
                ),
                _buildDrawerItem(
                  icon: Iconsax.calendar_1,
                  label: 'Calendar',
                  onTap: () {
                    Navigator.pop(context);
                    navigateToSubScreen(const UpcomingMeetingsScreen(), 'Meeting Calendar');
                  },
                ),
                if (userRole == 'admin')
                  _buildDrawerItem(
                    icon: Iconsax.activity,
                    label: 'Activity Track',
                    onTap: () {
                      Navigator.pop(context);
                      navigateToSubScreen(const ActivityTrackScreen(), 'Activity Tracker');
                    },
                  ),
                const Divider(thickness: 1),
                _buildDrawerItem(
                  icon: Iconsax.logout,
                  label: 'Logout',
                  color: Colors.red,
                  onTap: _confirmLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon, color: color ?? theme.colorScheme.primary),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? (isDark ? Colors.white70 : Colors.black87),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildCardBottomNav(bool isDark) {
    final th = Theme.of(context);
    final items = _currentItems;

    return Container(
      // Outer padding so the card floats above the screen edge
      padding: EdgeInsets.fromLTRB(16, 0, 16, context.sh(0.02)),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: th.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: context.sh(0.01)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isActive = _selectedIndex == index;
            return _buildNavItem(
              item: items[index],
              isActive: isActive,
              isDark: isDark,
              primaryColor: th.colorScheme.primary,
              onTap: () => _onItemTapped(index),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required _NavItem item,
    required bool isActive,
    required bool isDark,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: context.sw(0.04),
          vertical: context.sh(0.01),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? primaryColor.withOpacity(isDark ? 0.2 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: context.sw(0.055),
              color: isActive
                  ? primaryColor
                  : isDark
                  ? Colors.white38
                  : Colors.black38,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: context.sw(0.025),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? primaryColor
                    : isDark
                    ? Colors.white38
                    : Colors.black38,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}