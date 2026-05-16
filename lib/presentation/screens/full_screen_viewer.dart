import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:paddy_scan/data/models/prediction_result.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';
import 'package:paddy_scan/presentation/widgets/universal_box_painter.dart';

class FullScreenViewer extends StatefulWidget {
  final String? base64Image;
  final String heroTag;
  final List<BoundingBox>? boundingBoxes;
  final double? sourceWidth;
  final double? sourceHeight;
  final String? diseaseLabel;
  final double? confidence;

  const FullScreenViewer({
    super.key,
    this.base64Image,
    required this.heroTag,
    this.boundingBoxes,
    this.sourceWidth,
    this.sourceHeight,
    this.diseaseLabel,
    this.confidence,
  });

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
  bool _showBoxes = true;
  bool _showAppBar = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.base64Image == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: Center(
          child: Text(
            l10n.imageNotAvailable,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final bool hasBoundingBoxes =
        widget.boundingBoxes != null && widget.boundingBoxes!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Image + Bounding Boxes ──────────────────────────────
          SizedBox.expand(
            child: Hero(
              tag: widget.heroTag,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _showAppBar = !_showAppBar),
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: EdgeInsets.zero,
                  minScale: 0.5,
                  maxScale: 4.0,
                  clipBehavior: Clip.none,
                  child: SizedBox.expand(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: Image.memory(
                            base64Decode(widget.base64Image!),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                l10n.couldNotDecodeImage,
                                style:
                                    const TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        if (hasBoundingBoxes)
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: _showBoxes ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: CustomPaint(
                                painter: UniversalBoxPainter(
                                  boxes: widget.boundingBoxes!,
                                  sourceW: widget.sourceWidth ?? 1.0,
                                  sourceH: widget.sourceHeight ?? 1.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Box Count Badge ─────────────────────────────────────
          if (hasBoundingBoxes)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showBoxes ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.grain,
                            color: Colors.greenAccent, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          widget.boundingBoxes!.length == 1
                              ? l10n.diseaseAreaDetected(
                                  widget.boundingBoxes!.length)
                              : l10n.diseaseAreasDetected(
                                  widget.boundingBoxes!.length),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── App Bar (tap image to hide/show) ────────────────────
          AnimatedSlide(
            offset: _showAppBar ? Offset.zero : const Offset(0, -1),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: SafeArea(
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      if (widget.diseaseLabel != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.diseaseLabel!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.confidence != null)
                                Row(
                                  children: [
                                    const Icon(Icons.analytics_outlined,
                                        color: Colors.white60, size: 11),
                                    const SizedBox(width: 3),
                                    Text(
                                      l10n.confidencePercent(
                                        (widget.confidence! * 100)
                                            .toStringAsFixed(1),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        )
                      else
                        const Spacer(),

                      // Bounding boxes toggle — only shown when boxes exist
                      if (hasBoundingBoxes)
                        Tooltip(
                          message:
                              _showBoxes ? l10n.boxesOn : l10n.boxesOff,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(
                                right: 8, top: 8, bottom: 8),
                            decoration: BoxDecoration(
                              color: _showBoxes
                                  ? Colors.green.withValues(alpha: 0.8)
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              constraints: const BoxConstraints(
                                  minWidth: 36, minHeight: 36),
                              padding: const EdgeInsets.all(6),
                              icon: Icon(
                                _showBoxes
                                    ? Icons.crop_free
                                    : Icons.crop_free_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _showBoxes = !_showBoxes),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
