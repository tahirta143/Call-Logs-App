import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../constants/api_config.dart';
import '../../helpers/api_service.dart';
import '../../model/stock/item_model.dart';
import '../../model/stock/service_model.dart';
import '../../model/stock/stock_models.dart';

class StockProvider with ChangeNotifier {
  bool isLoading = false;
  String message = '';
  
  // Lists
  List<ItemData> items = [];
  List<ServiceData> services = [];
  List<OpeningStockData> openingStock = [];
  List<ItemRateData> itemRates = [];
   List<QuotationData> quotations = [];
   List<EstimationData> estimations = [];
   List<CustomerData> customers = [];
  
  // Summaries
  Map<String, dynamic> estimationSummary = {};
  double usdToPkrRate = 278.0; // Default fallback
  
  // Setup Options
  List<Map<String, String>> itemTypes = [];
  List<Map<String, String>> categories = [];
  List<Map<String, String>> subCategories = []; // [{name: 'Sub', categoryId: '1'}]
  List<Map<String, String>> manufacturers = [];
  List<Map<String, String>> suppliers = [];
  List<Map<String, String>> units = [];
  List<Map<String, String>> locations = [];

  File? selectedItemImage;
  final picker = ImagePicker();

  Future<void> pickItemImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedItemImage = File(picked.path);
      notifyListeners();
    }
  }

  void clearItemImage() {
    selectedItemImage = null;
    notifyListeners();
  }

  /// Robustly extracts the row list from various potential API response formats
  /// Supporting deeper nesting seen in React services (payload.data.data.key)
  List<dynamic> _extractRows(dynamic data, {String? context}) {
    if (data == null) return [];
    
    if (data is Map<String, dynamic>) {
      final potentialKeys = [
        'customers', 'customer',
        'services', 'service',
        'estimations', 'estimation',
        'itemRates', 'item_rates',
        'itemDefinitions', 'item_definitions',
        'quotations', 'quotation',
        'openingStock', 'opening_stock',
        'itemTypes', 'item_types',
        'categories', 'category',
        'subCategories', 'sub_categories',
        'manufacturers', 'manufacturer',
        'suppliers', 'supplier',
        'units', 'unit',
        'locations', 'location',
        'data', 'rows', 'items'
      ];
      
      // Level 1: Root check
      for (var key in potentialKeys) {
        if (data[key] is List) {
          if (kDebugMode) print("StockProvider: Extracted ${data[key].length} rows for $context from root key '$key'");
          return data[key];
        }
      }

      // Level 2: Nested 'data' check
      if (data['data'] is Map) {
        final nested = data['data'] as Map<String, dynamic>;
        for (var key in potentialKeys) {
          if (nested[key] is List) {
            if (kDebugMode) print("StockProvider: Extracted ${nested[key].length} rows for $context from nested data['$key']");
            return nested[key];
          }
        }
        
        // Level 3: Double nested 'data.data' check (found in React itemRateService)
        if (nested['data'] is Map) {
          final doubleNested = nested['data'] as Map<String, dynamic>;
          for (var key in potentialKeys) {
            if (doubleNested[key] is List) {
              if (kDebugMode) print("StockProvider: Extracted ${doubleNested[key].length} rows for $context from double nested data.data['$key']");
              return doubleNested[key];
            }
          }
          // Level 4: Fallback for data.data as direct list
          if (nested['data'] is List) {
            if (kDebugMode) print("StockProvider: Extracted ${nested['data'].length} rows for $context from data['data'] list");
            return nested['data'];
          }
        }

        // Fallback for direct data list
        if (data['data'] is List) {
          if (kDebugMode) print("StockProvider: Extracted ${data['data'].length} rows for $context from root data list");
          return data['data'];
        }
      }

      // Level 5: Deep inspection for any list (fallback)
      for (var entry in data.entries) {
        if (entry.value is List) {
          if (kDebugMode) print("StockProvider: Found list in unknown key '${entry.key}' for $context");
          return entry.value;
        }
      }
    }
    
    if (data is List) {
      if (kDebugMode) print("StockProvider: Data for $context is a direct list of ${data.length} items");
      return data;
    }
    
    if (kDebugMode) print("StockProvider WARNING: Could not find any list data for $context in response");
    return [];
  }

  // --- ITEM DEFINITION ---

  Future<void> fetchItems({String search = ''}) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final uri = Uri.parse(ApiConfig.itemDefinitionsUrl).replace(queryParameters: {'search': search});
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rows = _extractRows(data);
        items = rows.map((e) => ItemData.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print("StockProvider Error (fetchItems): $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveItem({required Map<String, String> data, String? id}) async {
    isLoading = true;
    message = '';
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final url = id == null ? ApiConfig.itemDefinitionsUrl : "${ApiConfig.itemDefinitionsUrl}/$id";
      
      var request = http.MultipartRequest(id == null ? 'POST' : 'PUT', Uri.parse(url));
      request.headers.addAll(headers);
      request.fields.addAll(data);

      if (selectedItemImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          selectedItemImage!.path,
          filename: selectedItemImage!.path.split('/').last,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final resData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        message = resData['message'] ?? 'Saved successfully';
        await fetchItems();
        selectedItemImage = null;
        return true;
      } else {
        message = resData['message'] ?? 'Failed to save';
        return false;
      }
    } catch (e) {
      message = "Error: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteItem(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final response = await http.delete(Uri.parse("${ApiConfig.itemDefinitionsUrl}/$id"), headers: headers);
      if (response.statusCode == 200) {
        await fetchItems();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("StockProvider Error (deleteItem): $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // --- SERVICES & PRODUCTS ---

  Future<void> fetchServices({String search = ''}) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final uri = Uri.parse(ApiConfig.servicesUrl).replace(queryParameters: {'search': search});
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rows = _extractRows(data, context: 'Services');
        services = rows.map((e) => ServiceData.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print("StockProvider Error (fetchServices): $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveService({required Map<String, dynamic> data, String? id}) async {
    isLoading = true;
    message = '';
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final url = id == null ? ApiConfig.servicesUrl : "${ApiConfig.servicesUrl}/$id";
      
      final response = id == null 
          ? await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data))
          : await http.put(Uri.parse(url), headers: headers, body: jsonEncode(data));
      
      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        message = resData['message'] ?? 'Saved successfully';
        await fetchServices();
        return true;
      } else {
        message = resData['message'] ?? 'Failed to save';
        return false;
      }
    } catch (e) {
      message = "Error: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteService(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final response = await http.delete(Uri.parse("${ApiConfig.servicesUrl}/$id"), headers: headers);
      if (response.statusCode == 200) {
        await fetchServices();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("StockProvider Error (deleteService): $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // --- OPENING STOCK ---

  Future<void> fetchOpeningStock({String search = '', String? type, String? category, String? subCategory}) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final params = {'search': search};
      if (type != null && type.isNotEmpty) params['item_type_name'] = type;
      if (category != null && category.isNotEmpty) params['category_name'] = category;
      if (subCategory != null && subCategory.isNotEmpty) params['sub_category_name'] = subCategory;

      final uri = Uri.parse(ApiConfig.openingStockUrl).replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rows = _extractRows(data, context: 'Opening Stock');
        openingStock = rows.map((e) => OpeningStockData.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print("StockProvider Error (fetchOpeningStock): $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateOpeningStock(String id, Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final response = await http.put(
        Uri.parse("${ApiConfig.openingStockUrl}/$id"),
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        message = 'Stock updated successfully';
        return true;
      }
    } catch (e) {
      message = "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // --- ITEM RATES ---

  Future<void> fetchItemRates({String search = ''}) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final uri = Uri.parse(ApiConfig.itemRatesUrl).replace(queryParameters: {'search': search});
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rows = _extractRows(data, context: 'Item Rates');
        itemRates = rows.map((e) => ItemRateData.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("StockProvider Error (fetchItemRates): $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveItemRate({required Map<String, dynamic> data, String? id}) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final url = id == null ? ApiConfig.itemRatesUrl : "${ApiConfig.itemRatesUrl}/$id";
      final response = id == null 
          ? await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data))
          : await http.put(Uri.parse(url), headers: headers, body: jsonEncode(data));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchItemRates();
        return true;
      } else {
        if (kDebugMode) print("ItemRate Save Failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print("ItemRate Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteItemRate(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final response = await http.delete(Uri.parse("${ApiConfig.itemRatesUrl}/$id"), headers: headers);
      if (response.statusCode == 200) {
        await fetchItemRates();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("DeleteRate Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // --- QUOTATIONS ---

  Future<void> fetchQuotations({String search = ''}) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final uri = Uri.parse(ApiConfig.quotationsUrl).replace(queryParameters: {'search': search});
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rows = _extractRows(data, context: 'Quotations');
        quotations = rows.map((e) => QuotationData.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print("StockProvider Error (fetchQuotations): $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveQuotation({required Map<String, dynamic> data, String? id}) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final url = id == null ? ApiConfig.quotationsUrl : "${ApiConfig.quotationsUrl}/$id";
      final response = id == null 
          ? await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data))
          : await http.put(Uri.parse(url), headers: headers, body: jsonEncode(data));
      
      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        message = resData['message'] ?? 'Quotation saved successfully';
        await fetchQuotations();
        return true;
      } else {
        message = resData['message'] ?? 'Failed to save quotation';
        return false;
      }
    } catch (e) {
      message = "Error: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reviseQuotation(String sourceId, Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final url = "${ApiConfig.quotationsRevisionUrl}/$sourceId";
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));
      
      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        message = resData['message'] ?? 'Revision saved successfully';
        await fetchQuotations();
        return true;
      } else {
        message = resData['message'] ?? 'Failed to save revision';
        return false;
      }
    } catch (e) {
      message = "Error: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuotationById(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(Uri.parse("${ApiConfig.quotationsUrl}/$id"), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final item = data['data'] ?? data;
        // Optionally update the list if needed, or just return it
        // For now, we usually just need the data in the dialog
      }
    } catch (e) {
      if (kDebugMode) print("FetchQuotationById Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getNextQuotationNo(String letterType) async {
    try {
      final headers = await ApiService.authHeader();
      final uri = Uri.parse("${ApiConfig.quotationsNextNoUrl}/$letterType");
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
    } catch (e) {
      if (kDebugMode) print("NextQuotationNo Error: $e");
    }
    return {};
  }

  Future<Map<String, dynamic>> getNextRevisionId() async {
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(Uri.parse(ApiConfig.quotationsNextRevisionUrl), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
    } catch (e) {
      if (kDebugMode) print("NextRevisionId Error: $e");
    }
    return {};
  }

  Future<QuotationData?> fetchQuotationByRevision(String revisionId) async {
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(Uri.parse("${ApiConfig.quotationsRevisionUrl}/$revisionId"), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final item = data['data'] ?? data;
        return QuotationData.fromJson(item);
      }
    } catch (e) {
      if (kDebugMode) print("FetchByRevision Error: $e");
    }
    return null;
  }

  Future<bool> deleteQuotation(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final response = await http.delete(Uri.parse("${ApiConfig.quotationsUrl}/$id"), headers: headers);
      if (response.statusCode == 200) {
        await fetchQuotations();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("DeleteQuotation Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // --- ESTIMATIONS ---

  Future<void> fetchEstimations({String search = ''}) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final uri = Uri.parse(ApiConfig.estimationsUrl).replace(queryParameters: {'search': search});
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rows = _extractRows(data, context: 'Estimations');
        estimations = rows.map((e) => EstimationData.fromJson(e)).toList();
        estimationSummary = data['summary'] ?? (data['data'] is Map ? data['data']['summary'] ?? {} : {});
      }
    } catch (e) {
      if (kDebugMode) print("StockProvider Error (fetchEstimations): $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveEstimation({required Map<String, dynamic> data, String? id}) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final url = id == null ? ApiConfig.estimationsUrl : "${ApiConfig.estimationsUrl}/$id";
      final response = id == null 
          ? await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data))
          : await http.put(Uri.parse(url), headers: headers, body: jsonEncode(data));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchEstimations();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("SaveEstimation Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  String generateNextEstimationId() {
    if (estimations.isEmpty) return 'EST-0001';

    final estimateIds = estimations
        .map((item) => item.estimateId?.trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    if (estimateIds.isEmpty) return 'EST-0001';

    final idRegex = RegExp(r'^(.*?)(\d+)$');
    Map<String, dynamic>? bestMatch;

    for (final id in estimateIds) {
      final match = idRegex.firstMatch(id);
      if (match == null) continue;

      final prefix = match.group(1) ?? '';
      final numericPart = match.group(2) ?? '';
      final numericValue = int.tryParse(numericPart) ?? 0;

      if (bestMatch == null || numericValue > bestMatch['numericValue']) {
        bestMatch = {
          'prefix': prefix,
          'numericValue': numericValue,
          'width': numericPart.length,
        };
      }
    }

    if (bestMatch == null) return 'EST-0001';

    final nextNumericValue = (bestMatch['numericValue'] + 1).toString().padLeft(bestMatch['width'], '0');
    return '${bestMatch['prefix']}$nextNumericValue';
  }

  Future<EstimationData?> fetchEstimationById(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(Uri.parse("${ApiConfig.estimationsUrl}/$id"), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final item = data['data'] ?? data;
        return EstimationData.fromJson(item);
      }
    } catch (e) {
      if (kDebugMode) print("FetchEstimationById Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<bool> deleteEstimation(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      final headers = await ApiService.authHeader();
      final response = await http.delete(Uri.parse("${ApiConfig.estimationsUrl}/$id"), headers: headers);
      if (response.statusCode == 200) {
        await fetchEstimations();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("DeleteEstimation Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }


  // --- SETUP OPTIONS ---

  Future<void> loadSetupOptions() async {
    try {
      final headers = await ApiService.authHeader();
      
      final responses = await Future.wait([
        http.get(Uri.parse(ApiConfig.itemTypesUrl).replace(queryParameters: {'status': 'active'}), headers: headers),
        http.get(Uri.parse(ApiConfig.categoriesUrl).replace(queryParameters: {'status': 'active'}), headers: headers),
        http.get(Uri.parse(ApiConfig.subCategoriesUrl).replace(queryParameters: {'status': 'active'}), headers: headers),
        http.get(Uri.parse(ApiConfig.manufacturersUrl).replace(queryParameters: {'status': 'active'}), headers: headers),
        http.get(Uri.parse(ApiConfig.suppliersUrl).replace(queryParameters: {'status': 'active'}), headers: headers),
        http.get(Uri.parse(ApiConfig.unitsUrl).replace(queryParameters: {'status': 'active'}), headers: headers),
        http.get(Uri.parse(ApiConfig.locationsUrl).replace(queryParameters: {'status': 'active'}), headers: headers),
      ]);

      if (responses[0].statusCode == 200) {
        final data = jsonDecode(responses[0].body);
        final List rows = _extractRows(data, context: 'Item Types');
        itemTypes = rows.map((e) => {
          'name': e['item_type_name']?.toString() ?? e['name']?.toString() ?? '',
          'id': e['id']?.toString() ?? e['_id']?.toString() ?? '',
        }).where((e) => e['name']!.isNotEmpty).toList();
      }
      
      if (responses[1].statusCode == 200) {
        final data = jsonDecode(responses[1].body);
        final List rows = _extractRows(data, context: 'Categories');
        categories = rows.map((e) => {
          'name': e['category_name']?.toString() ?? e['name']?.toString() ?? '',
          'id': e['id']?.toString() ?? e['_id']?.toString() ?? '',
        }).where((e) => e['name']!.isNotEmpty).toList();
      }

      if (responses[2].statusCode == 200) {
        final data = jsonDecode(responses[2].body);
        final List rows = _extractRows(data, context: 'Sub Categories');
        subCategories = rows.map((e) => {
          'name': e['sub_category_name']?.toString() ?? e['name']?.toString() ?? '',
          'id': e['id']?.toString() ?? e['_id']?.toString() ?? '',
          'categoryId': e['category_id']?.toString() ?? '',
          'categoryName': e['category_name']?.toString() ?? '',
        }).toList();
      }

      if (responses[3].statusCode == 200) {
        final data = jsonDecode(responses[3].body);
        final List rows = _extractRows(data, context: 'Manufacturers');
        manufacturers = rows.map((e) => {
          'name': e['manufacturer_name']?.toString() ?? e['name']?.toString() ?? '',
          'id': e['id']?.toString() ?? e['_id']?.toString() ?? '',
        }).where((e) => e['name']!.isNotEmpty).toList();
      }

      if (responses[4].statusCode == 200) {
        final data = jsonDecode(responses[4].body);
        final List rows = _extractRows(data, context: 'Suppliers');
        suppliers = rows.map((e) => {
          'name': e['supplier_name']?.toString() ?? e['name']?.toString() ?? '',
          'id': e['id']?.toString() ?? e['_id']?.toString() ?? '',
        }).where((e) => e['name']!.isNotEmpty).toList();
      }

      if (responses[5].statusCode == 200) {
        final data = jsonDecode(responses[5].body);
        final List rows = _extractRows(data, context: 'Units');
        units = rows.map((e) => {
          'name': e['unit_name']?.toString() ?? e['name']?.toString() ?? '',
          'id': e['id']?.toString() ?? e['_id']?.toString() ?? '',
        }).where((e) => e['name']!.isNotEmpty).toList();
      }

      if (responses[6].statusCode == 200) {
        final data = jsonDecode(responses[6].body);
        final List rows = _extractRows(data, context: 'Locations');
        locations = rows.map((e) => {
          'name': e['location_name']?.toString() ?? e['name']?.toString() ?? '',
          'id': e['id']?.toString() ?? e['_id']?.toString() ?? '',
        }).where((e) => e['name']!.isNotEmpty).toList();
      }

      // Concurrent loading like React's Promise.all
      // Each fetch method already calls notifyListeners(), 
      // but waiting for them here ensures the dialog dependencies are met.
      await Future.wait([
        fetchCustomers(),
        fetchItemRates(),
        fetchServices(),
        fetchEstimations(),
      ]);
      
      // Final notification to ensure any derived options lists update
      notifyListeners();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("StockProvider Error (loadSetupOptions): $e");
    }
  }

  Future<CustomerData?> fetchCustomerById(String id) async {
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(Uri.parse("${ApiConfig.customersUrl}/$id"), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final item = data['data'] ?? data;
        return CustomerData.fromJson(item);
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching customer by id: $e");
    }
    return null;
  }

  Future<void> fetchUsdRate() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.exchangeRateUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success') {
          usdToPkrRate = (data['conversion_rate'] as num).toDouble();
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching USD rate: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchItemDetails(String itemId) async {
    try {
      final headers = await ApiService.authHeader();
      final response = await http.get(Uri.parse("${ApiConfig.itemDetailsUrl}/$itemId"), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching item details: $e");
    }
    return null;
  }

  Future<String?> fetchQuotationId(String supplierId, String itemId) async {
    try {
      final headers = await ApiService.authHeader();
      final uri = Uri.parse(ApiConfig.itemQuotationUrl).replace(queryParameters: {
        'supplierId': supplierId,
        'itemId': itemId,
      });
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']?.toString() ?? data.toString();
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching quotation id: $e");
    }
    return null;
  }

  Future<void> fetchCustomers({String search = ''}) async {
    try {
      final headers = await ApiService.authHeader();
      final uri = Uri.parse(ApiConfig.customersUrl).replace(queryParameters: {'search': search});
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rows = _extractRows(data, context: 'Customers');
        customers = rows.map((e) => CustomerData.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching customers: $e");
    }
  }
}
