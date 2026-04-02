//                 final timeline = meeting['timeline'] ?? '';
//
//                 return Card(
//                   margin: const EdgeInsets.symmetric(
//                       horizontal: 12, vertical: 6),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: ListTile(
//                     leading: const Icon(Icons.business,
//                         color: Colors.indigo),
//                     title: Text(company),
//                     subtitle:
//                     Text("Person: $person\nTime: $times"),
//                     trailing: Text(
//                       timeline,
//                       style: TextStyle(
//                         color: timeline == 'Hold'
//                             ? Colors.orange
//                             : Colors.green,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../compoents/premium_header.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import '../../Provider/MeetingProvider/Meeting_provider.dart';
import '../../compoents/responsive_helper.dart';

class UpcomingMeetingsScreen extends StatefulWidget {
  const UpcomingMeetingsScreen({super.key});

  @override
  State<UpcomingMeetingsScreen> createState() =>
      _UpcomingMeetingsScreenState();
}

class _UpcomingMeetingsScreenState extends State<UpcomingMeetingsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String _selectedFilter = 'All';
  List<String> _filters = ['All', 'Hold', 'Follow Up', 'Completed'];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    Future.microtask(() =>
        Provider.of<MeetingProvider>(context, listen: false)
            .fetchUpcomingMeetings());
  }

  void _refreshMeetings() {
    Provider.of<MeetingProvider>(context, listen: false)
        .fetchUpcomingMeetings();
  }

  List<dynamic> _getFilteredMeetings(MeetingProvider provider) {
    final meetingsForSelectedDate = _selectedDay != null
        ? provider.getMeetingsForDate(_selectedDay!)
        : [];

    if (_selectedFilter == 'All') {
      return meetingsForSelectedDate;
    }

    return meetingsForSelectedDate.where((meeting) {
      final timeline = meeting['timeline']?.toString().toLowerCase() ?? '';
      return timeline.toLowerCase().contains(_selectedFilter.toLowerCase());
    }).toList();
  }

  Color _getTimelineColor(String timeline) {
    switch (timeline.toLowerCase()) {
      case 'hold':
        return Colors.orange;
      case 'follow up':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTimelineIcon(String timeline) {
    switch (timeline.toLowerCase()) {
      case 'hold':
        return Icons.pause_circle_filled_rounded;
      case 'follow up':
        return Icons.update_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final provider = Provider.of<MeetingProvider>(context);

    final meetingsForSelectedDate = _selectedDay != null
        ? provider.getMeetingsForDate(_selectedDay!)
        : [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Upcoming Meetings',
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
      body: Consumer<MeetingProvider>(
        builder: (context, provider, child) {
          final filteredMeetings = _getFilteredMeetings(provider);

          return Column(
            children: [
              PremiumActionHeader(
                controller: TextEditingController(),
                onChanged: (value) {},
                onAddTap: () {},
                showAdd: false,
                hintText: "Search meetings...",
              ),
              if (_filters.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedFilter = filter);
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
                    : _buildContent(theme, isDarkMode, provider, filteredMeetings),
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

  Widget _buildContent(
      ThemeData theme,
      bool isDarkMode,
      MeetingProvider provider,
      List<dynamic> filteredMeetings,
      ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: PremiumCard(
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredMeetings.isEmpty
              ? _buildEmptyState(isDarkMode)
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filteredMeetings.length,
            itemBuilder: (context, index) {
              final meeting = filteredMeetings[index];
              final company = meeting['companyName'] ?? "Unknown";
              final person = meeting['person'] ?? "No Contact";
              final times = (meeting['times'] as List)
                  .map((t) => t.toString())
                  .join(", ");
              final timeline = meeting['timeline']?.toString() ?? '';
              final timelineColor = _getTimelineColor(timeline);
              final timelineIcon = _getTimelineIcon(timeline);

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
                                company,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: timelineColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: timelineColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(timelineIcon, size: 12, color: timelineColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeline,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: timelineColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Contact Person
                        _buildDetailRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Contact Person',
                          value: person,
                          theme: theme,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 8),

                        // Meeting Time
                        _buildDetailRow(
                          icon: Icons.access_time_rounded,
                          label: 'Meeting Time',
                          value: times,
                          theme: theme,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Meetings Scheduled',
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
              'No meetings are scheduled for the selected date',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
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