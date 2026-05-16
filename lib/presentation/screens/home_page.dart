import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';
import 'dart:ui'; // Required for Glassmorphism (Blur)
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_state.dart';
import '../blocs/home/home_event.dart';
import '../screens/full_screen_viewer.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/theme_colors.dart';
import '../widgets/image_picker_buttons.dart';
import '../widgets/image_display_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    // Animation for the "Scanning" laser line
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No inner Scaffold — MainShell's Scaffold handles nav bar and safe area.
    // Without this, MediaQuery.padding.bottom is zeroed by the inner Scaffold,
    // causing content to scroll behind the bottom navigation bar.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Layer 1: base background colour ──────────────────────────
        Positioned.fill(
          child: ColoredBox(
            color: isDark ? const Color(0xFF080E08) : const Color(0xFFF4FAF4),
          ),
        ),

        // ── Layer 2: organic blobs ────────────────────────────────────
        IgnorePointer(child: _PageBackground(isDark: isDark)),

        // ── Layer 3: page content ─────────────────────────────────────
        SafeArea(
          bottom: false,
          child: BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state.status.isSuccess &&
                  state.result != null &&
                  !state.hasNavigated) {
                context.push('/result', extra: {
                  'result': state.result!,
                  'imageBytes': state.imageData?.base64 != null
                      ? base64Decode(state.imageData!.base64!)
                      : null,
                  'imagePath': state.imageData?.path,
                });
                context.read<HomeBloc>().add(const MarkAsNavigatedEvent());
              }
              if (state.status.isError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ??
                        AppLocalizations.of(context).unknownError),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      _buildMainUI(context, state, constraints),
                      if (state.status == PredictionStatus.loading)
                        _buildLoadingOverlay(),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainUI(
    BuildContext context,
    HomeState state,
    BoxConstraints constraints,
  ) {
    final l10n = AppLocalizations.of(context);

    final bottomPad = MediaQuery.of(context).padding.bottom;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Compact inline header — no sticky SliverAppBar
        SliverToBoxAdapter(child: _buildCompactHeader(state.isConnected)),

        // Image preview
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: _buildImagePreview(state),
          ),
        ),

        // Analysis settings + button
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.analysisSettings,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildModeGrid(context, state.selectedMode),
                const SizedBox(height: 20),
                _buildAnalyzeButton(context, state),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- UI Components ---

  Widget _buildImagePreview(HomeState state) {
    final bool hasImage =
        state.imageData != null && state.imageData!.base64 != null;
    final tc = ThemeColors.of(context);
    final screenH = MediaQuery.of(context).size.height;
    // Scales with screen — fills space above the settings cards
    final imageHeight = (screenH * 0.32).clamp(210.0, 320.0);
    return Container(
      height: imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: tc.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: hasImage
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FullScreenViewer(
                              base64Image: state.imageData!.base64,
                              heroTag: 'image_hero',
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'image_hero',
                        child: ImageDisplayWidget(imageData: state.imageData!),
                      ),
                    )
                  : _buildUploadPlaceholder(context),
            ),
            // The Wipe/Reset Button (Only shows when an image exists)
            if (hasImage)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    context.read<HomeBloc>().add(const CheckServerConnection());
                    context.read<HomeBloc>().add(const ResetStateEvent());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        // Soft centre glow
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.09),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Scanner corner brackets
        Positioned.fill(
          child: CustomPaint(painter: _ScannerBracketsPainter()),
        ),

        // Logo watermark — bottom right
        Positioned(
          bottom: 14,
          right: 14,
          child: Opacity(
            opacity: 0.10,
            child: Image.asset('assets/Logo.png', width: 32),
          ),
        ),

        // Original upload UI — unchanged
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined,
                  size: 35, color: Colors.green.shade200),
              const SizedBox(height: 12),
              Text(
                l10n.uploadImage,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const ImagePickerButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Scanning Box
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Positioned(
                          top: _scanController.value * 240,
                          child: Container(
                            width: 250,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.greenAccent.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    spreadRadius: 4)
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Text(l10n.analyzing, // 👈 replaced
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const CircularProgressIndicator(color: Colors.greenAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeGrid(BuildContext context, AnalysisMode selectedMode) {
    final tc = ThemeColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on available width
        final isWide = constraints.maxWidth > 600;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: AnalysisMode.values.map((mode) {
            Color color;
            IconData icon;
            String description;

            final l10n = AppLocalizations.of(context);

            switch (mode) {
              case AnalysisMode.classify:
                color = const Color(0xFF1565C0);
                icon = Icons.psychology_outlined;
                description = l10n.classifyDesc;
                break;
              case AnalysisMode.detect:
                color = const Color(0xFFE65100);
                icon = Icons.center_focus_weak_rounded;
                description = l10n.detectDesc;
                break;
              case AnalysisMode.diagnose:
                color = const Color(0xFF6A1B9A);
                icon = Icons.biotech_outlined;
                description = l10n.diagnoseDesc;
                break;
            }

            // Card width adapts to screen
            final cardWidth = isWide
                ? (constraints.maxWidth - 40) / 3 // 3 per row on wide
                : (constraints.maxWidth - 24) / 3; // 3 per row on mobile

            return _buildAnalysisCard(
              context,
              tc: tc,
              mode: mode,
              currentMode: selectedMode,
              title: mode.displayName,
              icon: icon,
              description: description,
              activeColor: color,
              width: cardWidth,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context, {
    required ThemeColors tc,
    required AnalysisMode mode,
    required AnalysisMode currentMode,
    required String title,
    required IconData icon,
    required String description,
    required Color activeColor,
    required double width,
  }) {
    final bool isSelected = mode == currentMode;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<HomeBloc>().add(ChangeModeEvent(mode));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : tc.cardUnselected,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? activeColor : tc.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.12)
                    : tc.cardUnselected,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? activeColor : tc.iconUnselected,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : tc.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? activeColor.withValues(alpha: 0.7)
                    : tc.textSecondary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            // Selected indicator dot
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context, HomeState state) {
    final bool hasImage = state.imageData != null;
    final tc = ThemeColors.of(context);

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 54,
        width: MediaQuery.of(context).size.width * 0.65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: hasImage
              ? const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                )
              : null,
          color: hasImage ? null : tc.cardUnselected,
          border: hasImage
              ? null
              : Border.all(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.55),
                  width: 1.5,
                ),
          boxShadow: hasImage
              ? [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: hasImage
                ? () => context.read<HomeBloc>().add(const AnalyzeImageEvent())
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: hasImage ? Colors.white : tc.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).startAnalysis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: hasImage ? Colors.white : tc.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(bool isConnected) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Image.asset('assets/Logo.png', height: 28, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.tagline,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _ServerStatusIndicator(
            isConnected: isConnected,
            onTap: () =>
                context.read<HomeBloc>().add(const CheckServerConnection()),
          ),
        ],
      ),
    );
  }
}

// ── Page background ───────────────────────────────────────────────────────────

class _PageBackground extends StatelessWidget {
  const _PageBackground({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // top-left — mostly off screen, only the fade bleeds in
        Positioned(
          top: -140, left: -140,
          child: _Blob(size: 320, color: isDark ? const Color(0xFF1B5E20).withValues(alpha: 0.55) : const Color(0xFFA5D6A7).withValues(alpha: 0.65)),
        ),
        // top-right
        Positioned(
          top: -80, right: -140,
          child: _Blob(size: 280, color: isDark ? const Color(0xFF004D40).withValues(alpha: 0.40) : const Color(0xFFB2DFDB).withValues(alpha: 0.55)),
        ),
        // bottom-right — large, mostly clipped
        Positioned(
          bottom: -160, right: -140,
          child: _Blob(size: 360, color: isDark ? const Color(0xFF1B5E20).withValues(alpha: 0.45) : const Color(0xFFA5D6A7).withValues(alpha: 0.50)),
        ),
        // bottom-left
        Positioned(
          bottom: -100, left: -120,
          child: _Blob(size: 260, color: isDark ? const Color(0xFF00695C).withValues(alpha: 0.28) : const Color(0xFFDCEDC8).withValues(alpha: 0.65)),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _ScannerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF69F0AE).withValues(alpha: 0.60)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const m = 20.0;
    const l = 20.0;

    canvas.drawLine(Offset(m, m + l), Offset(m, m), paint);
    canvas.drawLine(Offset(m, m), Offset(m + l, m), paint);
    canvas.drawLine(Offset(size.width - m - l, m), Offset(size.width - m, m), paint);
    canvas.drawLine(Offset(size.width - m, m), Offset(size.width - m, m + l), paint);
    canvas.drawLine(Offset(m, size.height - m - l), Offset(m, size.height - m), paint);
    canvas.drawLine(Offset(m, size.height - m), Offset(m + l, size.height - m), paint);
    canvas.drawLine(Offset(size.width - m - l, size.height - m), Offset(size.width - m, size.height - m), paint);
    canvas.drawLine(Offset(size.width - m, size.height - m), Offset(size.width - m, size.height - m - l), paint);
  }

  @override
  bool shouldRepaint(_ScannerBracketsPainter old) => false;
}

// ── Server Status Indicator ────────────────────────────────────────────────
class _ServerStatusIndicator extends StatefulWidget {
  final bool isConnected;
  final VoidCallback? onTap;

  const _ServerStatusIndicator({required this.isConnected, this.onTap});

  @override
  State<_ServerStatusIndicator> createState() => _ServerStatusIndicatorState();
}

class _ServerStatusIndicatorState extends State<_ServerStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _ringAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(_ServerStatusIndicator old) {
    super.didUpdateWidget(old);
    // Stop pulsing when disconnected, restart when connected
    if (widget.isConnected && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!widget.isConnected && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        widget.isConnected ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final Color bgColor = widget.isConnected
        ? const Color(0xFF00E676).withValues(alpha: 0.12)
        : const Color(0xFFFF5252).withValues(alpha: 0.12);
    final Color borderColor = widget.isConnected
        ? const Color(0xFF00E676).withValues(alpha: 0.45)
        : const Color(0xFFFF5252).withValues(alpha: 0.45);

    return Tooltip(
      message:
          widget.isConnected ? 'Server Connected' : 'Server Disconnected — Tap to retry',
      textStyle: const TextStyle(color: Colors.white, fontSize: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A1F),
        borderRadius: BorderRadius.circular(8),
      ),
      preferBelow: true,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated sonar icon
              SizedBox(
                width: 22,
                height: 22,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Expanding ring (only when connected)
                    if (widget.isConnected)
                      AnimatedBuilder(
                        animation: _ringAnim,
                        builder: (_, __) => Container(
                          width: 8 + _ringAnim.value * 14,
                          height: 8 + _ringAnim.value * 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: activeColor.withValues(
                                  alpha: (1 - _ringAnim.value) * 0.7),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    // Core icon
                    Icon(
                      widget.isConnected
                          ? Icons.sensors
                          : Icons.sensors_off_rounded,
                      size: 13,
                      color: activeColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              // Status label
              Text(
                widget.isConnected ? 'LIVE' : 'OFFLINE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: activeColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
