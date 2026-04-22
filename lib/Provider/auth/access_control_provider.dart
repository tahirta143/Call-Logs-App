import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/permission_helper.dart';

class AccessControlProvider with ChangeNotifier {
  List<String> _permissions = [];
  String? _role;
  bool _isLoading = true;

  List<String> get permissions => _permissions;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAdmin => _role?.toLowerCase() == 'admin';

  AccessControlProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('role');
    _permissions = await PermissionHelper.getStoredPermissions();
    _isLoading = false;
    notifyListeners();
  }

  /// Checks if the user has a specific permission (e.g. 'INVENTORY.ITEM_DEFINITION.READ')
  bool can(String permissionName) {
    if (isAdmin) return true;
    return PermissionHelper.hasPermissionSync(permissionName, _permissions);
  }

  /// Specific action helpers for better readability in UI
  bool canRead(String resource) => can('$resource.READ');
  bool canCreate(String resource) => can('$resource.CREATE');
  bool canUpdate(String resource) => can('$resource.UPDATE');
  bool canDelete(String resource) => can('$resource.DELETE');

  /// Refreshes permissions (e.g. after login or profile update)
  Future<void> refresh() async {
    await init();
  }
}
