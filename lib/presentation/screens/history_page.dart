import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:paddy_scan/core/constants/app_colors.dart' as palette;
import 'package:paddy_scan/core/constants/theme_colors.dart';
import 'package:paddy_scan/data/models/scan_history.dart';
import 'package:paddy_scan/data/services/history_service.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';
import 'package:paddy_scan/presentation/screens/full_screen_viewer.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  final _service = HistoryService();
  List<ScanHistory> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Called by MainShell whenever the History tab becomes active.
  Future<void> refresh() => _load();

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final entries = await _service.getAll();
    if (mounted) setState(() { _entries = entries; _loading = false; });
  }

  Future<void> _delete(String id) async {
    await _service.delete(id);
    setState(() => _entries.removeWhere((e) => e.id == id));
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context);
    final tc = ThemeColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.clearHistoryTitle),
        content: Text(l10n.clearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel,
                style: TextStyle(color: tc.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.clearAll,
                style: const TextStyle(color: palette.AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.clearAll();
      if (mounted) setState(() => _entries.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: palette.AppColors.primary,
        child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            backgroundColor: palette.AppColors.primary,
            automaticallyImplyLeading: false,
            actions: [
              if (_entries.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Colors.white),
                  tooltip: l10n.clearAll,
                  onPressed: _clearAll,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(50, 0, 0, 15),
              title: Text(
                l10n.scanHistory,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: 0.15,
                    child: Icon(Icons.history, size: 140, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(
                  color: palette.AppColors.primary)),
            )
          else if (_entries.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_toggle_off,
                        size: 72, color: tc.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noScansYet,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: tc.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.scanResultsPlaceholder,
                      style: TextStyle(fontSize: 13, color: tc.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildCard(_entries[i], l10n, tc),
                  childCount: _entries.length,
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildCard(ScanHistory entry, AppLocalizations l10n, ThemeColors tc) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: palette.AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _delete(entry.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: tc.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: _buildLeadingThumbnail(entry),
          title: Text(
            entry.diseaseName,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: tc.textPrimary),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                _buildModeBadge(entry.mode, tc),
                const SizedBox(width: 8),
                Text(
                  _formatDate(entry.timestamp, l10n),
                  style: TextStyle(fontSize: 11, color: tc.textSecondary),
                ),
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(entry.confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _confidenceColor(entry.confidence),
                ),
              ),
              Text(l10n.confidenceLabel,
                  style: TextStyle(fontSize: 10, color: tc.textSecondary)),
            ],
          ),
          children: [_buildDetails(entry, l10n, tc)],
        ),
      ),
    );
  }

  /// Builds a cross-platform image widget from a stored path.
  /// On web: path starts with "web:" → loads bytes from SharedPreferences.
  /// On native: path is an absolute file path → uses Image.file().
  Widget _buildStoredImage({
    required String path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget Function()? errorWidget,
  }) {
    final fallback = errorWidget?.call() ?? const SizedBox.shrink();
    if (HistoryService.isWebPath(path)) {
      return FutureBuilder<Uint8List?>(
        future: HistoryService.loadImageBytes(path),
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return SizedBox(
              width: width,
              height: height,
              child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final bytes = snap.data;
          if (bytes == null || bytes.isEmpty) return fallback;
          return Image.memory(bytes,
              width: width, height: height, fit: fit,
              errorBuilder: (_, __, ___) => fallback);
        },
      );
    }
    // Native file path
    if (kIsWeb) return fallback; // safety — shouldn't happen
    return Image.file(File(path),
        width: width, height: height, fit: fit,
        errorBuilder: (_, __, ___) => fallback);
  }

  Future<void> _openFullScreen(String path, String diseaseLabel) async {
    Uint8List? bytes;
    if (HistoryService.isWebPath(path)) {
      bytes = await HistoryService.loadImageBytes(path);
    } else if (!kIsWeb) {
      bytes = await File(path).readAsBytes();
    }
    if (bytes == null || bytes.isEmpty || !mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FullScreenViewer(
        base64Image: base64Encode(bytes!),
        heroTag: 'history_$path',
        diseaseLabel: diseaseLabel,
      ),
    ));
  }

  Widget _buildImageRow(ScanHistory entry, AppLocalizations l10n, ThemeColors tc) {
    final tiles = <Widget>[];

    if (entry.processedImagePath != null) {
      tiles.add(_buildThumb(
        path: entry.processedImagePath!,
        label: l10n.aiProcessed,
        labelColor: palette.AppColors.primary,
        diseaseLabel: entry.diseaseName,
      ));
    }
    if (entry.imagePath != null) {
      tiles.add(_buildThumb(
        path: entry.imagePath!,
        label: l10n.original,
        labelColor: tc.textSecondary,
        diseaseLabel: entry.diseaseName,
      ));
    }

    if (tiles.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }

  Widget _buildThumb({
    required String path,
    required String label,
    required Color labelColor,
    required String diseaseLabel,
  }) {
    return GestureDetector(
      onTap: () => _openFullScreen(path, diseaseLabel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, size: 11, color: labelColor),
              const SizedBox(width: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: labelColor)),
              const SizedBox(width: 4),
              Icon(Icons.open_in_full, size: 9, color: labelColor.withValues(alpha: 0.6)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: _buildStoredImage(path: path, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(ScanHistory entry, AppLocalizations l10n, ThemeColors tc) {
    final hasAnyImage = entry.imagePath != null || entry.processedImagePath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: tc.divider),
        const SizedBox(height: 12),

        if (hasAnyImage) ...[
          _buildImageRow(entry, l10n, tc),
          const SizedBox(height: 12),
        ],

        if (entry.affectedAreas != null || entry.severity != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (entry.affectedAreas != null)
                _chip(Icons.grain,
                    entry.affectedAreas! == 1
                        ? l10n.diseaseAreaDetected(entry.affectedAreas!)
                        : l10n.diseaseAreasDetected(entry.affectedAreas!),
                    Colors.orange),
              if (entry.severity != null)
                _chip(Icons.warning_amber_outlined,
                    '${entry.severity} ${l10n.severity.toLowerCase()}',
                    _severityColor(entry.severity!)),
              if (entry.affectedPercentage != null)
                _chip(Icons.percent,
                    '${entry.affectedPercentage!.toStringAsFixed(1)}% ${l10n.area.toLowerCase()}',
                    Colors.blue),
            ],
          ),

        if (entry.topPredictions != null &&
            entry.topPredictions!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.otherPossibilities,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: tc.textSecondary)),
          const SizedBox(height: 6),
          ...entry.topPredictions!.take(3).map((p) {
            final name = p['name'] as String? ?? '';
            final conf = (p['confidence'] as num?)?.toDouble() ?? 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(name,
                        style: TextStyle(
                            fontSize: 13, color: tc.textPrimary)),
                  ),
                  Text('${(conf * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: tc.textSecondary)),
                ],
              ),
            );
          }),
        ],

        if (entry.aiResponse != null && entry.aiResponse!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.aiDiagnosis,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: tc.textSecondary)),
          const SizedBox(height: 6),
          Text(
            entry.aiResponse!,
            style: TextStyle(
                fontSize: 13, color: tc.textPrimary, height: 1.5),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildLeadingThumbnail(ScanHistory entry) {
    // Prefer AI-processed image, fall back to original, then disease icon
    final imagePath = entry.processedImagePath ?? entry.imagePath;
    final color = entry.diseaseName.toLowerCase() == 'healthy'
        ? const Color(0xFF2E7D32)
        : const Color(0xFFD32F2F);

    if (imagePath != null) {
      return GestureDetector(
        onTap: () => _openFullScreen(imagePath, entry.diseaseName),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildStoredImage(
            path: imagePath,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorWidget: () => _diseaseIconFallback(color, entry),
          ),
        ),
      );
    }

    return _diseaseIconFallback(color, entry);
  }

  Widget _diseaseIconFallback(Color color, ScanHistory entry) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        entry.diseaseName.toLowerCase() == 'healthy'
            ? Icons.eco
            : Icons.coronavirus_outlined,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildModeBadge(String mode, ThemeColors tc) {
    final colors = {
      'classify': const Color(0xFF1565C0),
      'detect': const Color(0xFF6A1B9A),
      'diagnose': const Color(0xFF2E7D32),
    };
    final color = colors[mode] ?? tc.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        mode,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.3),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF2E7D32);
    if (confidence >= 0.6) return const Color(0xFFF57C00);
    return const Color(0xFFD32F2F);
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe': return const Color(0xFFD32F2F);
      case 'moderate': return const Color(0xFFF57C00);
      case 'mild': return const Color(0xFFFBC02D);
      default: return const Color(0xFF2E7D32);
    }
  }

  String _formatDate(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.timeYesterday;
    if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
