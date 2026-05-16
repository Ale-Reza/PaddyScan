import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';
import 'package:paddy_scan/presentation/blocs/home/home_event.dart';
import '../../core/constants/enums.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_state.dart';

class UploadProgressWidget extends StatelessWidget {
  final HomeState state;

  const UploadProgressWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == PredictionStatus.loading) {
      return _buildLoadingWidget(context);
    }

    if (state.status == PredictionStatus.success && state.result != null) {
      return _buildSuccessWidget(context);
    }

    if (state.status == PredictionStatus.error && state.errorMessage != null) {
      return _buildErrorWidget(context, state.errorMessage!);
    }

    if (state.imageData != null && state.result == null) {
      return _buildReadyWidget(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildReadyWidget(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.image_search, size: 48, color: Colors.blue),
          const SizedBox(height: 12),
          Text(l10n.imageReady,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.read<HomeBloc>().add(AnalyzeImageEvent()),
              icon: const Icon(Icons.analytics),
              label: Text(l10n.analyzeImage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.green),
          const SizedBox(height: 16),
          Text(l10n.analyzing,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSuccessWidget(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = state.result!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          _buildResultRow(l10n.result, result.label, isBold: true),
          _buildConfidenceBar(result.confidence),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.read<HomeBloc>().add(ResetStateEvent()),
            child: Text(l10n.newScan),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded,
                size: 40, color: Colors.red.shade700),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.analysisFailed,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade900),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Colors.red.shade700, height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.read<HomeBloc>().add(const ResetStateEvent()),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.tryAgain),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context
                      .read<HomeBloc>()
                      .add(const CheckServerConnection()),
                  icon: const Icon(Icons.wifi_tethering),
                  label: Text(l10n.checkServer),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(double confidence) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
              confidence > 0.7 ? Colors.green : Colors.orange),
        ),
        Text('${(confidence * 100).toStringAsFixed(1)}%'),
      ],
    );
  }
}
