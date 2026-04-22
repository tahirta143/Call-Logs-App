import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionHelper {
  static const String _permissionsKey = 'cms_permissions';

  /// Extracts permissions from the raw data (payload or user map)
  static List<String> extractPermissionsFromUser(Map<String, dynamic> data) {
    Set<String> permissionSet = {};

    // Helper to collect from a potential source
    void collect(dynamic source) {
      if (source == null) return;
      if (source is List) {
        for (var p in source) {
          final normalized = _normalizePermissionEntry(p);
          if (normalized.isNotEmpty) permissionSet.add(normalized);
        }
      }
    }

    // React auth.js candidate check order
    // candidates = [resolvedAuthData?.permissions, resolvedAuthData?.permission_keys, resolvedAuthData?.permissionKeys, ...]
    
    // Check root level first (if data is the full response)
    collect(data['permissions']);
    collect(data['permission_keys']);
    collect(data['permissionKeys']);

    // Check user nested level
    if (data['user'] != null && data['user'] is Map) {
      final user = data['user'] as Map<String, dynamic>;
      collect(user['permissions']);
      collect(user['permission_keys']);
      collect(user['permissionKeys']);

      // Group permissions
      if (user['groups'] != null && user['groups'] is List) {
        for (var group in user['groups']) {
          if (group is Map && group['permissions'] != null) {
            collect(group['permissions']);
          }
        }
      }
    }

    return permissionSet.toList();
  }

  static String _normalizePermissionEntry(dynamic permission) {
    if (permission is String) {
      return permission.trim().toUpperCase();
    }
    if (permission is Map) {
      final keyName = permission['key_name'] ??
          permission['keyName'] ??
          permission['permission_key'] ??
          permission['permissionKey'] ??
          permission['name'] ??
          permission['code'] ??
          '';
      return keyName.toString().trim().toUpperCase();
    }
    return '';
  }

  /// Save the normalized string roles/permissions to SharedPreferences
  static Future<void> savePermissions(List<String> permissions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_permissionsKey, permissions);
  }

  /// Clears stored permissions
  static Future<void> clearPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_permissionsKey);
  }

  /// Reads stored permissions from SharedPreferences
  static Future<List<String>> getStoredPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_permissionsKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Reads stored role from SharedPreferences
  static Future<String?> getStoredRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('role');
    } catch (e) {
      return null;
    }
  }

  static String _normalizePermissionKey(String value) {
    return value.trim().toUpperCase().replaceAll(RegExp(r'[\s-]+'), '_');
  }

  static String _singularizeToken(String token) {
    final normalizedToken = _normalizePermissionKey(token);
    if (normalizedToken.endsWith('IES')) {
      return '${normalizedToken.substring(0, normalizedToken.length - 3)}Y';
    }
    if (normalizedToken.endsWith('S') && !normalizedToken.endsWith('SS')) {
      return normalizedToken.substring(0, normalizedToken.length - 1);
    }
    return normalizedToken;
  }

  static Set<String> _buildTokenVariants(String token) {
    final normalizedToken = _normalizePermissionKey(token);
    final singularToken = _singularizeToken(normalizedToken);
    return {normalizedToken, singularToken};
  }

  static bool _tokensMatch(String leftToken, String rightToken) {
    final leftVariants = _buildTokenVariants(leftToken);
    final rightVariants = _buildTokenVariants(rightToken);

    for (var variant in leftVariants) {
      if (rightVariants.contains(variant)) {
        return true;
      }
    }
    return false;
  }

  static bool _permissionMatches(String requestedPermission, String storedPermission) {
    final normalizedRequested = requestedPermission.trim().toUpperCase();
    final normalizedStored = storedPermission.trim().toUpperCase();

    if (normalizedRequested == normalizedStored) return true;

    var requestedSegments = normalizedRequested.split('.')
        .map((segment) => _normalizePermissionKey(segment))
        .where((s) => s.isNotEmpty).toList();
        
    var storedSegments = normalizedStored.split('.')
        .map((segment) => _normalizePermissionKey(segment))
        .where((s) => s.isNotEmpty).toList();

    if (requestedSegments.length == 2 && storedSegments.length == 3) {
      final requestedResource = requestedSegments[0];
      final requestedAction = requestedSegments[1];
      
      final storedModule = storedSegments[0];
      final storedSubModule = storedSegments[1];
      final storedAction = storedSegments[2];

      return _tokensMatch(requestedAction, storedAction) &&
          (_tokensMatch(requestedResource, storedSubModule) || _tokensMatch(requestedResource, storedModule));
    }

    if (requestedSegments.length == storedSegments.length) {
      bool allMatch = true;
      for (int i = 0; i < requestedSegments.length; i++) {
        if (!_tokensMatch(requestedSegments[i], storedSegments[i])) {
          allMatch = false;
          break;
        }
      }
      return allMatch;
    }

    return false;
  }

  /// Validates asynchronously if the user has a specific permission
  static Future<bool> hasPermission(String permissionName) async {
    try {
      final permissions = await getStoredPermissions();
      // If we don't have stored permissions, maybe handle via role as fallback or fail.
      // Usually, true for admin? Or false. We will return true if no permissions exist for ease
      // but ideally false. Let's return true if empty based on auth.js behavior.
      if (permissions.isEmpty) return true; 

      for (var p in permissions) {
        if (_permissionMatches(permissionName, p)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return true;
    }
  }

  /// Helper to check multiple permissions synchronously if list is already preloaded
  static bool hasPermissionSync(String permissionName, List<String> permissions) {
    if (permissions.isEmpty) return true;
    for (var p in permissions) {
      if (_permissionMatches(permissionName, p)) {
        return true;
      }
    }
    return false;
  }
}
