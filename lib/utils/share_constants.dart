import 'package:flutter/material.dart';

/// Constants for folder sharing functionality
class ShareConstants {
  // Access level values
  static const String accessView = 'view';
  static const String accessEdit = 'edit';
  static const String accessAdmin = 'admin';

  // Access level definitions with metadata
  static final List<Map<String, dynamic>> accessLevels = [
    {
      'value': accessView,
      'label': 'Can View',
      'icon': Icons.visibility,
      'description': 'Can only view folder contents',
    },
    {
      'value': accessEdit,
      'label': 'Can Edit',
      'icon': Icons.edit,
      'description': 'Can view and edit folder contents',
    },
    {
      'value': accessAdmin,
      'label': 'Admin',
      'icon': Icons.admin_panel_settings,
      'description': 'Full access including user management',
    },
  ];

  // Get access level display name
  static String getAccessLevelLabel(String accessLevel) {
    switch (accessLevel) {
      case accessAdmin:
        return 'Admin';
      case accessEdit:
        return 'Can Edit';
      case accessView:
        return 'Can View';
      default:
        return accessLevel;
    }
  }

  // Get access level color
  static Color getAccessLevelColor(String accessLevel) {
    switch (accessLevel) {
      case accessAdmin:
        return Colors.red;
      case accessEdit:
        return Colors.orange;
      case accessView:
      default:
        return Colors.blue;
    }
  }

  // Check if user can edit with this access level
  static bool canEdit(String accessLevel) {
    return accessLevel == accessEdit || accessLevel == accessAdmin;
  }

  // Check if user has admin access
  static bool isAdmin(String accessLevel) {
    return accessLevel == accessAdmin;
  }
}
