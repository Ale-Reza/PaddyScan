import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Pass the context if you want to show a dialog immediately
  Future<bool> requestPermission(
      Permission permission, BuildContext context) async {
    final status = await permission.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      // The user opted to never see the dialog again.
      // We must show a custom UI to guide them to Settings.
      // ignore: use_build_context_synchronously
      _showSettingsDialog(context, permission);
      return false;
    }

    return false;
  }

  void _showSettingsDialog(BuildContext context, Permission permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: Text(
          "This app needs ${permission.toString().split('.').last} access to identify rice diseases. Please enable it in system settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Built-in method to open the device settings
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
