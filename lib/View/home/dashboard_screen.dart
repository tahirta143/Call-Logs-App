//
// import 'package:flutter/material.dart';
// import 'package:infinity/View/Meeting_calender/AllMeeting.dart';
// import 'package:infinity/View/home/weekly_charts.dart';
// import 'package:provider/provider.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:table_calendar/table_calendar.dart';
//
//
// import '../../Provider/dashboard_provider.dart';
// import '../Activity_Track/Activity_Track_Screen.dart';
// import '../AssignScreen/AssignCustomer.dart';
// import '../Auths/Login_screen.dart';
// import '../Customer/customer_list.dart';
// import '../Meeting_calender/MeetingCalender.dart';
// import '../SuccessClientScreen/successClientProvider.dart';
// import '../call_logs_track/call_logs_track.dart';
// import '../followUpScreen/FollowUpScreen.dart';
// import '../monthly chats.dart';
// import '../products/product_screen.dart';
// import '../staff/staffListScreen.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
//
//
//
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen> {
//   String? userRole;
//   @override
//   @override
//   void initState() {
//     super.initState();
//     _loadUserRole();
//     Future.microtask(() {
//       final provider = Provider.of<DashBoardProvider>(context, listen: false);
//       provider.loadAllDashboardData();
//     });
//   }
//   Future<String?> _getUsername() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('username');
//   }
//   Future<void> _loadUserRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userRole = prefs.getString('role') ?? 'user'; // default = user
//     });
//     debugPrint("✅ User role loaded: $userRole");
//   }
//
//
//
//
//   Widget build(BuildContext context) {
//     final provider = Provider.of<DashBoardProvider>(context);
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Center(child: const Text("Dashboard",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//             letterSpacing: 1.2,
//           )),
//         ),
//           centerTitle: true,
//           elevation: 6,
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//       ),
//
//       // ✅ Drawer Menu Added
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: FutureBuilder<String?>(
//                 future: _getUsername(), // async method defined above
//                 builder: (context, snapshot) {
//                   final username = snapshot.data ?? "User";
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CircleAvatar(
//                         radius: 28,
//                         backgroundColor: Colors.white,
//                         child: Icon(
//                           Icons.person,
//                           color: Color(0xFF5B86E5),
//                           size: 35,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         'Welcome $username',
//                         style: const TextStyle(
//                           color: Colors.black87,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//
//             // Now add username text outside const
//             FutureBuilder<String?>(
//               future: _getUsername(),
//               builder: (context, snapshot) {
//                 final username = snapshot.data ?? "User";
//                 return Padding(
//                   padding: const EdgeInsets.only(left: 16.0, bottom: 10),
//                   child: Text(
//                     '',
//                     style: const TextStyle(
//                       color: Colors.black87,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//             ListTile(
//               leading: const Icon(Icons.dashboard, color: Color(0xFF5B86E5)),
//               title: const Text('Dashboard'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.meeting_room, color: Color(0xFF5B86E5)),
//               title: const Text('All Meeting detail'),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => NoDateMeetingScreen()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.follow_the_signs, color: Color(0xFF5B86E5)),
//               title: const Text('Follow Up'),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => FollowUpScreen()));
//               },
//             ),
//             if (userRole == 'admin')
//             ListTile(
//               leading: const Icon(Icons.assignment_ind, color: Color(0xFF5B86E5)),
//               title: const Text('Assign To'),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => UnassignCustomerScreen()));
//               },
//             ),
//             if (userRole == 'admin')
//               ListTile(
//                 leading: const Icon(Icons.phone, color: Color(0xFF5B86E5)),
//                 title: const Text('Call Track'),
//                 onTap: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => CallLogsScreen()));
//                 },
//               ),
//             ListTile(
//               leading: const Icon(Icons.done, color: Color(0xFF5B86E5)),
//               title: const Text('Success Client'),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => SuccessClientScreen()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.calendar_month, color: Color(0xFF5B86E5)),
//               title: const Text('Calendar'),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => UpcomingMeetingsScreen()));
//               },
//             ),
//             if (userRole == 'admin')
//             ListTile(
//               leading: const Icon(Icons.history_outlined, color: Color(0xFF5B86E5)),
//               title: const Text('Activity Track '),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => ActivityTrackScreen()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings, color: Color(0xFF5B86E5)),
//               title: const Text('Settings'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             const Divider(),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text('Logout'),
//               onTap: () async {
//                 Navigator.pop(context);
//                 final shouldLogout = await showDialog<bool>(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Confirm Logout'),
//                     content: const Text('Are you sure you want to logout?'),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context, false),
//                         child: const Text('Cancel'),
//                       ),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                         ),
//                         onPressed: () => Navigator.pop(context, true),
//                         child: const Text('Logout',),
//                       ),
//                     ],
//                   ),
//                 );
//                 if (shouldLogout == true) {
//                   final prefs = await SharedPreferences.getInstance();
//                   await prefs.clear();
//                   if (!context.mounted) return;
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => const LoginScreen()),
//                         (route) => false,
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//
//       body: SafeArea(
//         child:provider.isLoading
//             ? const Center(child: CircularProgressIndicator())
//
//             :
//         RefreshIndicator(
//           onRefresh: () async {
//             await provider.loadAllDashboardData();
//           },
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF5F8FF),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Wrap(
//                         spacing: 16,
//                         runSpacing: 16,
//                         children: [
//                           GestureDetector(
//                             onTap: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>CompanyListScreen()));},
//                               child: AnimatedDashboardCard(icon: Icons.person, title:'Customer', count:provider.totalCustomers.toString(), bcolor:Colors.green)),
//                           GestureDetector(
//                               onTap:userRole == 'admin'?
//                                   (){Navigator.push(context,MaterialPageRoute(builder: (context)=>ProductScreen()));}:() {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text("Access denied: Admins only"),
//                                     backgroundColor: Colors.redAccent,
//                                   ),
//                                 );
//                               },
//                               child: AnimatedDashboardCard(icon: Icons.shop, title:'Products', count:provider.totalProducts.toString(), bcolor:Colors.red)),
//                           GestureDetector(
//                               onTap:userRole == 'admin'?
//                                   (){Navigator.push(context,MaterialPageRoute(builder: (context)=>StaffScreen()));}:() {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text("Access denied: Admins only"),
//                                     backgroundColor: Colors.redAccent,
//                                   ),
//                                 );
//                               },
//                               child: AnimatedDashboardCard(icon: Icons.people_alt, title:'Staff', count:provider.totalStaffs.toString(), bcolor:Colors.blue)),
//                           AnimatedDashboardCard(icon: Icons.account_balance_wallet, title:'Transactions', count:provider.totalTransactions.toString(), bcolor:Colors.orange)
//
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20,),
//                   Text("Performance Summary",style: TextStyle(fontWeight: FontWeight.bold),),
//                   Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFFEEF2FF), Color(0xFFFFFFFF)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.indigo.withOpacity(0.15),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//                       child: Column(
//                         children: [
//                           provider.isLoading
//                               ? const CircularProgressIndicator()
//                               : Wrap(
//                             alignment: WrapAlignment.center,
//                             spacing: 20,      // space between graphs (horizontally)
//                             runSpacing: 20,   // space between rows (vertically)
//                             children: [
//                               _buildProgressCircle(
//                                 label: "Success Rate",
//                                 currentValue: provider.successRate,
//                                 maxValue: 100,
//                                 color: const Color(0xFF4CAF50),
//                               ),
//                               _buildProgressCircle(
//                                 label: "Pending Calls",
//                                 currentValue: provider.pendingCalls,
//                                 maxValue: 100,
//                                 color: const Color(0xFF2196F3),
//                               ),
//                               _buildProgressCircle(
//                                 label: "Follow Ups",
//                                 currentValue: provider.followUps,
//                                 maxValue: 100,
//                                 color: Colors.orange,
//                               ),
//                               // _buildProgressCircle(
//                               //   label: "Meetings",
//                               //   currentValue: provider.totalMeetings,
//                               //   maxValue: 100,
//                               //   color: const Color(0xFFF44336),
//                               // ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//
//
//
//
//                   SizedBox(height: 20),
//                   Text("Follow-up Meeting",style: TextStyle(fontWeight: FontWeight.bold),),
//                   Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: CalendarWidget(), // 👈 use calendar here
//                   ),
//                   SizedBox(height: 20),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: provider.monthlyTrends.isEmpty
//                         ? const Center(child: Text("No data available"))
//                         : MonthlyTrendsChart(
//                       totalCalls: provider.totalCalls,
//                       monthlyData: provider.monthlyTrends,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: WeeklyVolumeChart(
//                   totalCalls: provider.totalWeeklyCalls,
//                   weeklyData: provider.weeklyData,),
//               )
//                 ],
//               ),
//             ),
//               ),
//         ),
//           ),
//
//
//
//     );
//   }
//   double _total(List<Map<String, dynamic>> list) =>
//       list.fold(0, (sum, e) => sum + (e["value"] as double));
//   Widget _buildLegend(List<Map<String, dynamic>> data) {
//     return Wrap(
//       crossAxisAlignment: WrapCrossAlignment.start,
//       alignment: WrapAlignment.start,
//       spacing: 20,
//       runSpacing: 10,
//       children: data
//           .map((item) => Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircleAvatar(
//             backgroundColor: item["color"],
//             radius: 5,
//
//           ),
//           const SizedBox(width: 8),
//           Text(
//             "${item["title"]}: ${item["value"].toInt()}",
//             style: const TextStyle(fontSize: 16),
//           ),
//         ],
//       ))
//           .toList(),
//     );
//   }
//
//
//   // Function to build circular indicator
//   Widget _buildProgressCircle({
//     required String label,
//     required double currentValue,
//     required double maxValue,
//     required Color color,
//   }) {
//     final percent = (currentValue / maxValue).clamp(0.0, 1.0);
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CircularPercentIndicator(
//           radius: 40.0,
//           lineWidth: 8.0,
//           percent: percent,
//           center: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 currentValue.toStringAsFixed(0),
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               Text(
//                 "/${maxValue.toStringAsFixed(0)}",
//                 style: const TextStyle(fontSize: 10, color: Colors.grey),
//               ),
//             ],
//           ),
//           progressColor: color,
//           backgroundColor: color.withOpacity(0.2),
//           circularStrokeCap: CircularStrokeCap.round,
//         ),
//         const SizedBox(height: 6),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//         ),
//       ],
//     );
//   }
//
// }
// class AnimatedDashboardCard extends StatefulWidget {
//   final IconData icon;
//   final  String title;
//   final String count;
//   final Color bcolor;
//   const AnimatedDashboardCard({super.key, required this.icon, required this.title, required this.count, required this.bcolor});
//
//   @override
//   State<AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
// }
//
// class _AnimatedDashboardCardState extends State<AnimatedDashboardCard> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width / 2 - 24,
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       decoration: BoxDecoration(
//         color: widget.bcolor,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: widget.bcolor.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//        children: [
//          Icon(widget.icon,size: 32,color: Colors.white,),
//          const SizedBox(height: 10),
//     Text(widget.title,style: TextStyle(color: Colors.white),),
//          const SizedBox(height: 10),
//     Text(widget.count,style: TextStyle(color: Colors.white),),
//
//         ],
//       ),
//     );
//   }
// }
//
//
//
// class CalendarWidget extends StatefulWidget {
//   const CalendarWidget({super.key});
//
//   @override
//   State<CalendarWidget> createState() => _CalendarWidgetState();
// }
//
// class _CalendarWidgetState extends State<CalendarWidget> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<DashBoardProvider>(context);
//
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//       //  color: Colors.white,
//         color: const Color(0xFFF5F8FF),
//         boxShadow: [
//           BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)
//         ],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: TableCalendar(
//         firstDay: DateTime.utc(2024, 1, 1),
//         lastDay: DateTime.utc(2026, 12, 31),
//         focusedDay: _focusedDay,
//         selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//         calendarFormat: CalendarFormat.month,
//         onDaySelected: (selectedDay, focusedDay) {
//           setState(() {
//             _selectedDay = selectedDay;
//             _focusedDay = focusedDay;
//           });
//         },
//         calendarStyle: CalendarStyle(
//           todayDecoration: BoxDecoration(
//             color: Colors.indigo.shade300,
//             shape: BoxShape.circle,
//           ),
//           selectedDecoration: BoxDecoration(
//             color: Colors.indigo,
//             shape: BoxShape.circle,
//           ),
//         ),
//         calendarBuilders: CalendarBuilders(
//           defaultBuilder: (context, day, focusedDay) {
//             bool isMeeting = provider.isMeetingDay(day);
//             return Container(
//               margin: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: isMeeting ? Colors.greenAccent.withOpacity(0.8) : null,
//                 shape: BoxShape.circle,
//               ),
//               alignment: Alignment.center,
//               child: Text(
//                 '${day.day}',
//                 style: TextStyle(
//                   color: isMeeting ? Colors.white : Colors.black,
//                   fontWeight: isMeeting ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//
//     );
//   }
// }
//
//
//
//
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinity/Provider/theme_provider.dart';
import 'package:infinity/View/Meeting_calender/AllMeeting.dart';
import 'package:infinity/View/home/weekly_charts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../Provider/dashboard_provider.dart';
import '../../compoents/responsive_helper.dart';
// import '../../compoents/premium_header.dart';
import '../../compoents/premium_card.dart';
import 'package:iconsax/iconsax.dart';
import '../monthly chats.dart';
import '../staff/staffListScreen.dart';
import '../products/product_screen.dart';
import '../Customer/customer_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    Future.microtask(() {
      final provider = Provider.of<DashBoardProvider>(context, listen: false);
      provider.loadAllDashboardData();
    });
  }

  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? 'user';
    });
    debugPrint("✅ User role loaded: $userRole");
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashBoardProvider>(context);
    final theme = Theme.of(context);

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
                  _buildStatisticsCards(provider),

                  // Performance Section
                  _buildPerformanceSection(provider),

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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome to Infinity Dashboard',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.totalCalls} Total Calls | ${provider.totalCustomers} Customers',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.chart_3,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(DashBoardProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cards = [
      {
        'icon': Iconsax.profile_2user,
        'title': 'Customers',
        'count': provider.totalCustomers.toString(),
        'color': const Color(0xFF4CAF50),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CompanyListScreen()),
        ),
      },
      {
        'icon': Iconsax.box,
        'title': 'Products',
        'count': provider.totalProducts.toString(),
        'color': const Color(0xFFF44336),
        'onTap': userRole == 'admin'
            ? () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductScreen()),
        )
            : null,
      },
      {
        'icon': Iconsax.people,
        'title': 'Staff',
        'count': provider.totalStaffs.toString(),
        'color': const Color(0xFF2196F3),
        'onTap': userRole == 'admin'
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