import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_event.dart';

class ImagePickerButtons extends StatefulWidget {
  final VoidCallback? onCameraPressed;
  final VoidCallback? onGalleryPressed;

  const ImagePickerButtons({
    super.key,
    this.onCameraPressed,
    this.onGalleryPressed,
  });

  @override
  State<ImagePickerButtons> createState() => _ImagePickerButtonsState();
}

class _ImagePickerButtonsState extends State<ImagePickerButtons>
    with WidgetsBindingObserver {
  // Prevents re-triggering the system camera dialog after first denial.
  // Gallery needs no flag — image_picker handles its own picker UI directly.
  bool _cameraDeniedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // User may have granted camera in Settings — reset so next tap re-checks.
    if (state == AppLifecycleState.resumed && _cameraDeniedOnce) {
      setState(() => _cameraDeniedOnce = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (kIsWeb) {
      return Center(
        child: SizedBox(
          width: 220,
          child: _buildCompactButton(
            context,
            icon: Icons.upload_file_rounded,
            label: l10n.selectImage,
            color: Colors.green.shade700,
            onTap: widget.onGalleryPressed ??
                () => context
                    .read<HomeBloc>()
                    .add(const PickImageEvent(ImageSource.gallery)),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _buildCompactButton(
            context,
            icon: Icons.camera_alt_outlined,
            label: l10n.camera,
            color: Colors.blue.shade700,
            onTap: widget.onCameraPressed ??
                () => _handleMobilePick(context, isCamera: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCompactButton(
            context,
            icon: Icons.image_search_outlined,
            label: l10n.gallery,
            color: Colors.green.shade700,
            onTap: widget.onGalleryPressed ??
                () => _handleMobilePick(context, isCamera: false),
          ),
        ),
      ],
    );
  }

  Future<void> _handleMobilePick(BuildContext context,
      {required bool isCamera}) async {
    // Camera: skip system dialog if already denied this session.
    if (isCamera && _cameraDeniedOnce) {
      if (context.mounted) _showPermissionDeniedDialog(context, true);
      return;
    }

    // Capture bloc before any await so we never use BuildContext after a gap.
    final bloc = context.read<HomeBloc>();

    if (isCamera) {
      final status = await Permission.camera.status;

      if (status.isGranted || status.isLimited) {
        bloc.add(const PickImageEvent(ImageSource.camera));
        return;
      }

      if (status.isPermanentlyDenied || status.isRestricted) {
        if (context.mounted) _showPermissionDeniedDialog(context, true);
        return;
      }

      final result = await Permission.camera.request();
      if (result.isGranted || result.isLimited) {
        bloc.add(const PickImageEvent(ImageSource.camera));
      } else {
        setState(() => _cameraDeniedOnce = true);
        if (context.mounted) _showPermissionDeniedDialog(context, true);
      }
    } else {
      // Gallery: Android 13+ system photo-picker requires no special runtime
      // permission — let image_picker handle it directly.
      bloc.add(const PickImageEvent(ImageSource.gallery));
    }
  }

  Widget _buildCompactButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: color.withValues(alpha: 0.05),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              )),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context, bool isCamera) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
            isCamera ? l10n.cameraAccessRequired : l10n.galleryAccessRequired),
        content: Text(l10n.permissionRequired),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel,
                  style: TextStyle(color: Colors.grey.shade600))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }
}
