import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:infinity/model/staff_model/staffModel.dart';
import '../../constants/api_config.dart';
import '../../helpers/api_service.dart';

class StaffProvider with ChangeNotifier {
  bool isLoading = false;
  bool isSetupLoading = false;
  List<StaffData> staffs = [];
  String message = '';
  File? selectedImage;

  final picker = ImagePicker();
  
  // Setup Options
  List<String> departments = [];
  List<String> designations = [];
  List<String> employeeTypes = [];
  List<String> dutyShifts = [];
  List<String> banks = [];

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedImage = File(picked.path);
      notifyListeners();
    }
  }

  Future<void> fetchStaff({String search = ''}) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final uri = Uri.parse(ApiConfig.employeesUrl).replace(queryParameters: {
        'search': search,
        'q': search,
      });

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final staffModel = StaffModel.fromJson(jsonResponse);
        staffs = staffModel.data ?? [];
        if (kDebugMode) {
          print("✅ Loaded ${staffs.length} employees");
        }
      } else {
        if (kDebugMode) {
          print("❌ Failed to load employees: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ Error fetching employees: $e");
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> DeleteStaff(String staffId) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final response = await http.delete(
        Uri.parse('${ApiConfig.employeesUrl}/$staffId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await fetchStaff();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Error deleting employee: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> uploadStaff({
    required Map<String, String> employeeData,
  }) async {
    try {
      isLoading = true;
      message = '';
      notifyListeners();

      final headers = await ApiService.authHeader();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.employeesUrl),
      );

      request.headers.addAll(headers);
      request.fields.addAll(employeeData);

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            selectedImage!.path,
            filename: selectedImage!.path.split('/').last,
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonData = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        message = jsonData['message'] ?? 'Employee added successfully';
        await fetchStaff();
        selectedImage = null;
        return true;
      } else {
        message = jsonData['message'] ?? jsonData['error'] ?? 'Failed to add employee';
        return false;
      }
    } catch (e) {
      message = 'Error: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStaff({
    required String id,
    required Map<String, String> employeeData,
    File? image,
  }) async {
    try {
      isLoading = true;
      message = '';
      notifyListeners();

      final headers = await ApiService.authHeader();
      final uri = Uri.parse("${ApiConfig.employeesUrl}/$id");
      var request = http.MultipartRequest('PUT', uri);

      request.headers.addAll(headers);
      request.fields.addAll(employeeData);

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            image.path,
            filename: image.path.split('/').last,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonData = json.decode(responseBody);

      if (response.statusCode == 200) {
        message = 'Employee updated successfully';
        await fetchStaff();
        return true;
      } else {
        message = jsonData['message'] ?? 'Failed to update employee';
        return false;
      }
    } catch (e) {
      message = 'Error: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _extractRows(dynamic data, {String? context}) {
    if (data == null) return [];
    
    if (data is Map<String, dynamic>) {
      final potentialKeys = [
        'departments', 'department',
        'designations', 'designation',
        'employeeTypes', 'employee_types',
        'dutyShifts', 'duty_shifts',
        'banks', 'bank',
        'data', 'rows', 'items'
      ];
      
      for (var key in potentialKeys) {
        if (data[key] is List) return data[key];
      }

      if (data['data'] is Map) {
        final nested = data['data'] as Map<String, dynamic>;
        for (var key in potentialKeys) {
          if (nested[key] is List) return nested[key];
        }
        if (nested['data'] is List) return nested['data'];
      }

      if (data['data'] is List) return data['data'];

      for (var entry in data.entries) {
        if (entry.value is List) return entry.value;
      }
    }
    
    if (data is List) return data;
    return [];
  }

  void clearImage() {
    selectedImage = null;
    notifyListeners();
  }

  void clearForm() {
    selectedImage = null;
    notifyListeners();
  }
  
  Future<void> loadSetupOptions() async {
    try {
      isSetupLoading = true;
      notifyListeners();
      
      final headers = await ApiService.authHeader();
      
      if (kDebugMode) print("StaffProvider: Loading setup options...");

      final responses = await Future.wait([
        http.get(Uri.parse(ApiConfig.departmentsUrl), headers: headers),
        http.get(Uri.parse(ApiConfig.designationsUrl), headers: headers),
        http.get(Uri.parse(ApiConfig.employeeTypesUrl), headers: headers),
        http.get(Uri.parse(ApiConfig.dutyShiftsUrl), headers: headers),
        http.get(Uri.parse(ApiConfig.banksUrl), headers: headers),
      ]);

      if (kDebugMode) {
        print("StaffProvider: Responses received - Dept: ${responses[0].statusCode}, Desig: ${responses[1].statusCode}, Type: ${responses[2].statusCode}, Shift: ${responses[3].statusCode}, Bank: ${responses[4].statusCode}");
      }

      if (responses[0].statusCode == 200) {
        final data = jsonDecode(responses[0].body);
        final List rows = _extractRows(data, context: 'Departments');
        departments = rows.map((e) {
          if (e is String) return e;
          if (e is Map) {
            return e['department_name']?.toString() ?? 
                   e['departmentName']?.toString() ?? 
                   e['DepartmentName']?.toString() ?? 
                   e['name']?.toString() ?? '';
          }
          return '';
        }).where((e) => e.isNotEmpty).toList();
        if (kDebugMode) print("StaffProvider: Loaded ${departments.length} departments");
      }
      
      if (responses[1].statusCode == 200) {
        final data = jsonDecode(responses[1].body);
        final List rows = _extractRows(data, context: 'Designations');
        designations = rows.map((e) {
          if (e is String) return e;
          if (e is Map) {
            return e['designation_name']?.toString() ?? 
                   e['designationName']?.toString() ?? 
                   e['DesignationName']?.toString() ?? 
                   e['name']?.toString() ?? '';
          }
          return '';
        }).where((e) => e.isNotEmpty).toList();
        if (kDebugMode) print("StaffProvider: Loaded ${designations.length} designations");
      }

      if (responses[2].statusCode == 200) {
        final data = jsonDecode(responses[2].body);
        final List rows = _extractRows(data, context: 'Employee Types');
        employeeTypes = rows.map((e) {
          if (e is String) return e;
          if (e is Map) {
            return e['employee_type_name']?.toString() ?? 
                   e['typeName']?.toString() ?? 
                   e['name']?.toString() ?? '';
          }
          return '';
        }).where((e) => e.isNotEmpty).toList();
        if (kDebugMode) print("StaffProvider: Loaded ${employeeTypes.length} employee types");
      }

      if (responses[3].statusCode == 200) {
        final data = jsonDecode(responses[3].body);
        final List rows = _extractRows(data, context: 'Duty Shifts');
        dutyShifts = rows.map((e) {
          if (e is String) return e;
          if (e is Map) {
            return e['duty_shift_name']?.toString() ?? 
                   e['shift_name']?.toString() ?? 
                   e['shiftName']?.toString() ?? 
                   e['name']?.toString() ?? '';
          }
          return '';
        }).where((e) => e.isNotEmpty).toList();
        if (kDebugMode) print("StaffProvider: Loaded ${dutyShifts.length} duty shifts");
      }

      if (responses[4].statusCode == 200) {
        final data = jsonDecode(responses[4].body);
        final List rows = _extractRows(data, context: 'Banks');
        banks = rows.map((e) {
          if (e is String) return e;
          if (e is Map) {
            return e['bank_name']?.toString() ?? 
                   e['bankName']?.toString() ?? 
                   e['name']?.toString() ?? '';
          }
          return '';
        }).where((e) => e.isNotEmpty).toList();
        if (kDebugMode) print("StaffProvider: Loaded ${banks.length} banks");
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("StaffProvider Error (loadSetupOptions): $e");
    } finally {
      isSetupLoading = false;
      notifyListeners();
    }
  }
}




