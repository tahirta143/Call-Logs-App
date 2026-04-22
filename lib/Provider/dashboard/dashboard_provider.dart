import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/api_config.dart';
import '../../helpers/api_service.dart';

class DashBoardProvider with ChangeNotifier {
  String? errorMessage;
  int? totalProducts;
  int? totalCustomers;
  int? totalStaffs;
  int? totalTransactions;
  bool isLoading = false;
  double successRate = 0;
  double pendingCalls = 0;
  double followUps = 0;
  double totalMeetings = 0;
  int totalCalls = 0;
  List<Map<String, dynamic>> monthlyTrends = [];
  List<Map<String, dynamic>> weeklyData = [];
  int totalWeeklyCalls = 0;

  Future<void> loadAllDashboardData() async {
    isLoading = true;
    notifyListeners();

    await Future.wait([
      Performance_Summary(),
      fetchCalendarMeetings(),
      fetchMonthlyTrends(),
      fetchWeeklyTrends(),
      CountProduct(),
      CountCustomer(),
      CountStaff(),
      CountTransaction(),
    ]);

    isLoading = false;
    notifyListeners();
  }

  Future<void> Performance_Summary() async {
    try {
      final headers = await ApiService.authHeader();
      const url = '${ApiConfig.baseUrl}/dashboard/performance-summary';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result["success"] == true) {
          final data = result["data"];
          successRate = double.tryParse(data["successRate"].toString()) ?? 0.0;
          pendingCalls = double.tryParse(data["pendingCalls"].toString()) ?? 0.0;
          followUps = double.tryParse(data["followUps"].toString()) ?? 0.0;
          totalMeetings = double.tryParse(data["totalMeetings"].toString()) ?? 0.0;
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error Performance_Summary: $e");
    }
  }

  List<Map<String, dynamic>> get chartData => [
    {"title": "Success Rate", "value": successRate, "color": const Color(0xFF4CAF50)},
    {"title": "Pending Calls", "value": pendingCalls, "color": const Color(0xFF2196F3)},
    {"title": "Follow Ups", "value": followUps, "color": Colors.orange},
    {"title": "Total Meetings", "value": totalMeetings, "color": const Color(0xFFF44336)},
  ];
  
  List<DateTime> meetingDates = [];

  Future<void> fetchCalendarMeetings() async {
    final now = DateTime.now();
    final formattedMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    try {
      final headers = await ApiService.authHeader();
      final url = '${ApiConfig.baseUrl}/dashboard/calendar-meetings?month=$formattedMonth';
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true && data["data"] is List) {
          meetingDates = (data["data"] as List)
              .map((item) => DateTime.parse(item["date"]))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching meetings: $e");
    }
  }

  bool isMeetingDay(DateTime day) {
    return meetingDates.any(
          (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    );
  }

  Future<void> fetchMonthlyTrends() async {
    const url = '${ApiConfig.baseUrl}/dashboard/monthly-trends';
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result["success"] == true) {
          totalCalls = result["totalCalls"] ?? 0;
          monthlyTrends = List<Map<String, dynamic>>.from(result["data"]);
        }
      }
    } catch (e) {
      debugPrint("❌ Exception fetchMonthlyTrends: $e");
    }
  }
  
  Future<void> CountProduct() async {
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products/count'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        totalProducts = data['totalProducts'] ?? 0;
      }
    } catch (e) {
      debugPrint("❌ Exception CountProduct: $e");
    }
  }

  Future<void> CountCustomer() async {
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/customers/count'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        totalCustomers = data['totalCustomers'] ?? 0;
      }
    } catch (e) {
      debugPrint("❌ Exception CountCustomer: $e");
    }
  }

  Future<void> CountStaff() async {
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/employees/count'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        totalStaffs = data['totalEmployees'] ?? data['totalUsers'] ?? 0;
      }
    } catch (e) {
      debugPrint("❌ Exception CountStaff: $e");
    }
  }

  Future<void> CountTransaction() async {
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/total'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        totalTransactions = data['totalSales'] ?? 0;
      }
    } catch (e) {
      debugPrint("❌ Exception CountTransaction: $e");
    }
  }

  Future<void> fetchWeeklyTrends() async {
    const url = '${ApiConfig.baseUrl}/dashboard/weekly-volume';
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result["success"] == true && result["data"] != null) {
          weeklyData = List<Map<String, dynamic>>.from(result["data"]);
          totalWeeklyCalls = weeklyData.fold<int>(
            0,
            (sum, item) => sum + ((item["count"] ?? 0) as int),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Exception fetchWeeklyTrends: $e");
    }
  }
}
