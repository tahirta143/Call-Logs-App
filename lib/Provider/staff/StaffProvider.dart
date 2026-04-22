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
  List<StaffData> staffs = [];
  String message = '';
  File? selectedImage;

  final picker = ImagePicker();

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

  Future<void> DeleteStaff(String staffId) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final response = await http.delete(
        Uri.parse('${ApiConfig.employeesUrl}/$staffId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await fetchStaff();
        print('✅ employee deleted successfully: $data');
      } else {
        print('❌ Failed to delete employee. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error deleting employee: $e');
    }
    isLoading = false;
    notifyListeners();
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

  void clearImage() {
    selectedImage = null;
    notifyListeners();
  }

  void clearForm() {
    selectedImage = null;
    notifyListeners();
  }
}




