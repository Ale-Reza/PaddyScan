import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:paddy_scan/data/models/image_data.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';
// Note: We avoid importing dart:io at the top level to keep Web happy.

class ImageDisplayWidget extends StatelessWidget {
  final ImageData imageData;

  const ImageDisplayWidget({super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(l10n),
    );
  }

  Widget _buildImage(AppLocalizations l10n) {
    if (imageData.base64 != null && imageData.base64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(imageData.base64!),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              _buildErrorPlaceholder(l10n.couldNotLoadImage),
        );
      } catch (e) {
        return _buildErrorPlaceholder(l10n.couldNotLoadImage);
      }
    }

    return _buildErrorPlaceholder(
      kIsWeb ? l10n.imageDataMissing : l10n.pathAccessRestricted,
    );
  }

  Widget _buildErrorPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
