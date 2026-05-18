import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:paddy_scan/core/constants/api_endpoints.dart';
import 'package:paddy_scan/core/constants/disease_info.dart';
import 'package:paddy_scan/core/constants/enums.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';
import 'package:paddy_scan/presentation/blocs/home/home_bloc.dart';
import 'package:paddy_scan/presentation/blocs/home/home_event.dart';
import 'package:paddy_scan/presentation/screens/full_screen_viewer.dart';
import 'package:paddy_scan/presentation/widgets/universal_box_painter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/prediction_result.dart';
import '../../data/models/scan_history.dart';
import '../../data/services/history_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';

class ResultPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const ResultPage({super.key, required this.data});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late PredictionResult _result;
  Uint8List? _imageBytes;
  String? _imagePath; // file path fallback when bytes not available
  String _aiResponse = "";
  bool _isTyping = true;
  bool _aiLoaded = false;
  bool _useAI = true;
  bool _aiRetrying = false;
  Timer? _streamTimer;
  Uint8List? _processedImageBytes;

  @override
  void initState() {
    super.initState();
    _result = widget.data['result'] as PredictionResult;
    _imageBytes = widget.data['imageBytes'] as Uint8List?;
    _imagePath = widget.data['imagePath'] as String?;
    // If bytes are missing but path is available, load from file
    if (_imageBytes == null && _imagePath != null) {
      _loadImageFromPath(_imagePath!);
    }
    _loadProcessedUrl();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_aiLoaded) {
      _aiLoaded = true;
      _getAIElaboration();
    }
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    super.dispose();
  }

  // ── Streaming helpers ───────────────────────────────────────────────────────

  /// Reveals [fullText] word-by-word to simulate an AI typing effect.
  void _streamContent(String fullText) {
    _streamTimer?.cancel();
    final words = fullText.split(' ');
    int index = 0;
    if (mounted) {
      setState(() {
        _aiResponse = '';
        _isTyping = false;
      });
    }
    _streamTimer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (index < words.length) {
        setState(() => _aiResponse += (index == 0 ? '' : ' ') + words[index]);
        index++;
      } else {
        timer.cancel();
      }
    });
  }

  /// Called when the user taps the inline AI toggle on the result screen.
  Future<void> _onAIToggle(bool value) async {
    if (_aiRetrying) return;
    _streamTimer?.cancel();

    // Capture lang before any await — context may be gone after await
    final lang = mounted && Localizations.localeOf(context).languageCode == 'ur'
        ? 'Urdu'
        : 'English';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_diagnosis', value);
    if (mounted) setState(() => _useAI = value);

    if (!value) {
      // Show hardcoded report in the active language
      _streamContent(DiseaseInfo.getInfo(_result.label, lang: lang));
      return;
    }

    // Re-attempt AI elaboration
    _aiRetrying = true;
    if (mounted)
      setState(() {
        _aiResponse = '';
        _isTyping = true;
      });

    final preferredModel = prefs.getString('ai_model') ?? '';

    String? aiResult;
    if (_result.selectedMode != AnalysisMode.detect &&
        _result.label.toLowerCase() != 'unknown' &&
        _result.label.trim().isNotEmpty) {
      aiResult = await _callGemini(lang) ??
          await _callOpenRouterFallback(lang, preferredModel);
    }

    _aiRetrying = false;

    if (!mounted) return;
    if (aiResult != null) {
      setState(() {
        _aiResponse = aiResult!;
        _isTyping = false;
      });
    } else {
      _streamContent(DiseaseInfo.getInfo(_result.label, lang: lang));
    }
  }

  Future<void> _loadImageFromPath(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      if (mounted) setState(() => _imageBytes = bytes);
    } catch (_) {}
  }

  // Completer lets _updateHistory wait for the image download before saving
  final _processedImageCompleter = Completer<void>();

  Future<void> _loadProcessedUrl() async {
    if (_result.previewUrl == null) {
      _processedImageCompleter.complete(); // nothing to download
      return;
    }
    final base = await ApiEndpoints.getBaseUrl();
    final url = '$base${_result.previewUrl}';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        _processedImageBytes = response.bodyBytes;
      }
    } catch (_) {}

    _processedImageCompleter.complete(); // signal done (success or fail)
  }

  static const String _geminiApiKey = 'AIzaSyAZCqCekrO7ez649EuaS02NEJTY04lbXtc';

  // Gemini model cascade — tries each in order on failure
  // gemini-1.5-flash / gemini-1.5-flash-8b are deprecated (404) — do NOT re-add them
  static const List<String> _geminiModels = [
    'gemini-2.0-flash', // Primary: 1500 req/day, 15 RPM free tier
    'gemini-2.0-flash-lite', // Fallback: higher RPM, lower daily cap
  ];

  // Final fallback: OpenRouter free models (more options = more resilience)
  static const List<String> _fallbackModels = [
    'deepseek/deepseek-chat:free', // Strong reasoning, free via OpenRouter
    'meta-llama/llama-3.1-8b-instruct:free',
    'mistralai/mistral-7b-instruct:free',
    'google/gemma-2-9b-it:free',
    'meta-llama/llama-3.2-3b-instruct:free',
    'microsoft/phi-3-mini-128k-instruct:free',
  ];

  Future<void> _getAIElaboration() async {
    // Capture context-dependent values before any await
    final l10n = AppLocalizations.of(context);
    final String currentLang =
        Localizations.localeOf(context).languageCode == 'ur'
            ? 'Urdu'
            : 'English';

    // Read user settings
    final prefs = await SharedPreferences.getInstance();
    final aiEnabled = prefs.getBool('ai_diagnosis') ?? true;
    final preferredModel = prefs.getString('ai_model') ?? '';
    if (mounted) setState(() => _useAI = aiEnabled);

    // ── STEP 1: Save to history immediately so it appears right away ──
    final historyId = await _saveInitialHistory();

    // ── STEP 2: Run AI elaboration (slow — 10-60s) ──
    String? aiResult;
    if (!aiEnabled) {
      // AI disabled — stream the hardcoded report in the active language
      _streamContent(DiseaseInfo.getInfo(_result.label, lang: currentLang));
      aiResult = DiseaseInfo.getInfo(_result.label, lang: currentLang);
    } else if (_result.selectedMode == AnalysisMode.detect) {
      aiResult = l10n.aiNotAvailableDetection;
      if (mounted)
        setState(() {
          _aiResponse = aiResult!;
          _isTyping = false;
        });
    } else if (_result.label.toLowerCase() != "unknown" &&
        _result.label.trim().isNotEmpty) {
      if (mounted) {
        setState(() {
          _aiResponse = "";
          _isTyping = true;
        });
      }
      final liveResult = await _callGemini(currentLang) ??
          await _callOpenRouterFallback(currentLang, preferredModel);
      if (liveResult != null) {
        aiResult = liveResult;
        if (mounted)
          setState(() {
            _aiResponse = aiResult!;
            _isTyping = false;
          });
      } else {
        // Both AI providers failed — stream hardcoded fallback in active language
        final fallback = DiseaseInfo.getInfo(_result.label, lang: currentLang);
        aiResult = fallback;
        _streamContent(fallback);
      }
    }

    // ── STEP 3: Update history with AI response + processed image ──
    await _processedImageCompleter.future;
    await _updateHistory(historyId, aiResult);
  }

  /// Saves immediately with original image only — no AI response yet.
  Future<String> _saveInitialHistory() async {
    final service = HistoryService();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      // Get original image bytes — priority: in-memory → file path
      Uint8List? bytes = _imageBytes;
      if ((bytes == null || bytes.isEmpty) && _imagePath != null) {
        try {
          bytes = await File(_imagePath!).readAsBytes();
        } catch (_) {}
      }
      // Last resort: re-decode from the base64 stored in widget.data
      if (bytes == null || bytes.isEmpty) {
        final b64 = widget.data['imageBytes'];
        if (b64 is Uint8List && b64.isNotEmpty) bytes = b64;
      }
      final imagePath = (bytes != null && bytes.isNotEmpty)
          ? await service.saveImage(bytes, id)
          : null;

      final entry = ScanHistory(
        id: id,
        diseaseName: _result.label,
        confidence: _result.confidence,
        timestamp: DateTime.now(),
        mode: _result.selectedMode.name,
        severity: _result.severity,
        affectedAreas: _result.affectedAreas,
        affectedPercentage: _result.affectedPercentage,
        aiResponse: null,
        imagePath: imagePath,
        processedImagePath: null,
        topPredictions: _result.topPredictions
            ?.map((p) => {'name': p.name, 'confidence': p.confidence})
            .toList(),
      );
      await service.save(entry);
    } catch (_) {}
    return id;
  }

  /// Updates the saved entry with AI response and processed image.
  Future<void> _updateHistory(String id, String? aiResponse) async {
    try {
      final service = HistoryService();
      String? processedImagePath;
      if (_processedImageBytes != null) {
        processedImagePath =
            await service.saveImage(_processedImageBytes!, '${id}_processed');
      }
      await service.updateEntry(id,
          aiResponse: aiResponse, processedImagePath: processedImagePath);
    } catch (_) {}
  }

  Future<String?> _callGemini(String lang) async {
    final prompt = _buildPrompt(lang);
    for (final model in _geminiModels) {
      try {
        final response = await http
            .post(
              Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_geminiApiKey',
              ),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                "contents": [
                  {
                    "parts": [
                      {"text": prompt}
                    ]
                  }
                ],
                "generationConfig": {
                  "temperature": 0.4,
                  "maxOutputTokens": 800,
                },
              }),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 429) {
          print("=== Gemini $model: quota hit (429), trying next...");
          continue;
        }
        if (response.statusCode == 404) {
          print(
              "=== Gemini $model: model not found (404) — remove it from the list!");
          continue;
        }
        if (response.statusCode != 200) {
          print(
              "=== Gemini $model: failed (${response.statusCode}), trying next...");
          continue;
        }

        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String?;
        if (text == null || text.trim().isEmpty) continue;
        return text.trim();
      } catch (e) {
        print("=== Gemini $model exception: $e");
        continue;
      }
    }
    return null;
  }

  Future<String?> _callOpenRouterFallback(
      String lang, String preferredModel) async {
    final prompt = _buildPrompt(lang);
    // Put the user's preferred model first, then the rest (deduplicated)
    final ordered = [
      if (preferredModel.isNotEmpty) preferredModel,
      ..._fallbackModels.where((m) => m != preferredModel),
    ];
    for (final model in ordered) {
      try {
        final response = await http
            .post(
              Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer your_openrouter_api_key_here',
                'HTTP-Referer': 'https://paddyscan.app',
                'X-Title': 'PADDY_SCAN',
              },
              body: jsonEncode({
                'model': model,
                'messages': [
                  {'role': 'user', 'content': prompt}
                ],
              }),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 429 || response.statusCode != 200) continue;

        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'] as String?;
        if (text == null || text.trim().isEmpty) continue;
        return text.trim();
      } catch (e) {
        print("=== $model exception: $e");
        continue;
      }
    }
    return null;
  }

  String _buildPrompt(String lang) {
    final bool isUrdu = lang == 'Urdu';
    final s1 = isUrdu ? 'تعریف' : 'Definition';
    final s2 = isUrdu ? 'علامات' : 'Symptoms';
    final s3 = isUrdu ? 'علاج' : 'Remedies';
    final s1desc = isUrdu ? 'یہ بیماری کیا ہے' : 'what this disease is';
    final s2desc = isUrdu ? '3 اہم بصری علامات' : '3 key visual symptoms';
    final s3desc =
        isUrdu ? '3 قابل عمل علاج کے اقدامات' : '3 actionable treatment steps';
    final closing = isUrdu
        ? 'چاول کے کسان کے لیے عملی اور سادہ رکھیں۔'
        : 'Keep it practical for a rice farmer.';
    return '''Answer in $lang.
The rice plant disease detected is: **${_result.label}**.
${_result.selectedMode == AnalysisMode.diagnose && _result.topPredictions != null ? 'Other detected conditions: ${_result.topPredictions!.map((p) => p.name).join(', ')}.' : ''}
Provide a concise professional report with these sections:
1. **$s1** — $s1desc
2. **$s2** — $s2desc
3. **$s3** — $s3desc
$closing''';
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainResultCard(),
                  if (_result.affectedAreas != null) _buildDetectionStats(),
                  _buildTopPredictionsList(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(),
                  const SizedBox(height: 12),
                  _buildAIExpertCard(),
                  const SizedBox(height: 30),
                  _buildActionButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final l10n = AppLocalizations.of(context);
    final double sw = _result.sourceWidth ?? 1.0;
    final double sh = _result.sourceHeight ?? 1.0;
    final List<BoundingBox> boxes = _result.boundingBoxes ?? [];
    // Bounding boxes only meaningful in detect/diagnose modes
    final bool showBoxes = boxes.isNotEmpty &&
        (_result.selectedMode == AnalysisMode.detect ||
            _result.selectedMode == AnalysisMode.diagnose);

    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // --- IMAGE LAYER (always original) ---
            if (_imageBytes != null)
              Image.memory(
                _imageBytes!,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              )
            else
              Container(
                color: ThemeColors.of(context).card,
                child: Center(child: Text(l10n.imageNotAvailable)),
              ),

            // --- BOXES LAYER (detect / diagnose only) ---
            if (showBoxes)
              Positioned.fill(
                child: CustomPaint(
                  painter: UniversalBoxPainter(
                    boxes: boxes,
                    sourceW: sw,
                    sourceH: sh,
                  ),
                ),
              ),

            // --- GRADIENT OVERLAY ---
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),

            // --- TAP TO FULLSCREEN ---
            if (_imageBytes != null)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullScreenViewer(
                        base64Image: base64Encode(_imageBytes!),
                        heroTag: 'result_image_hero',
                        boundingBoxes: showBoxes ? _result.boundingBoxes : null,
                        sourceWidth: _result.sourceWidth,
                        sourceHeight: _result.sourceHeight,
                        diseaseLabel: _result.label,
                        confidence: _result.confidence,
                      ),
                    ),
                  ),
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildMainResultCard() {
    final l10n = AppLocalizations.of(context);
    final tc = ThemeColors.of(context);
    final color = AppColors.getConfidenceColor(_result.confidence);

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _result.selectedMode == AnalysisMode.detect
                      ? l10n.fieldSurvey // ✅
                      : l10n.diagnosticReport, // ✅
                  style: GoogleFonts.inter(
                      letterSpacing: 1.2,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  _result.label,
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
                if (_result.selectedMode == AnalysisMode.detect)
                  Text(
                    l10n.totalSpots(_result.affectedAreas ?? 0), // ✅
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          _buildCircularConfidence(color),
        ],
      ),
    );
  }

  Widget _buildDetectionStats() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(l10n.spots, "${_result.affectedAreas}", Icons.grain), // ✅
            _statItem(
                l10n.severity,
                _result.severity ?? "N/A", // ✅
                Icons.warning_amber_rounded),
            _statItem(
                l10n.area, // ✅
                "${_result.affectedPercentage?.toStringAsFixed(1)}%",
                Icons.pie_chart),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.orange[800]),
        const SizedBox(height: 4),
        Text(value,
            style:
                GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCircularConfidence(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 75,
          height: 75,
          child: CircularProgressIndicator(
            value: _result.confidence,
            strokeWidth: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          "${(_result.confidence * 100).toInt()}%",
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildAIExpertCard() {
    final tc = ThemeColors.of(context);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tc.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: _isTyping && _aiResponse.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : MarkdownBody(
              data: _aiResponse,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.inter(
                    fontSize: 15, height: 1.6, color: tc.textSecondary),
                strong: TextStyle(
                    fontWeight: FontWeight.bold, color: tc.textPrimary),
              ),
            ),
    );
  }

  Widget _buildTopPredictionsList() {
    if (_result.topPredictions == null || _result.topPredictions!.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final tc = ThemeColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.list_alt, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              l10n.alternativeMatches,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
              color: tc.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.softShadow),
          child: Column(
            children: _result.topPredictions!.map((pred) {
              final tc = ThemeColors.of(context);
              return ListTile(
                title: Text(pred.name,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500, color: tc.textPrimary)),
                trailing: Text(
                  "${(pred.confidence * 100).toStringAsFixed(1)}%",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, color: tc.textSecondary),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    final l10n = AppLocalizations.of(context);
    final tc = ThemeColors.of(context);
    return Row(
      children: [
        const Icon(Icons.auto_awesome, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.aiExpertDiagnosis,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: tc.textPrimary),
          ),
        ),
        // ── Inline AI on/off toggle ───────────────────────────────────────
        if (_result.selectedMode != AnalysisMode.detect)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _useAI ? 'AI' : 'Info',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _useAI ? AppColors.primary : tc.textSecondary,
                ),
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: _useAI,
                  onChanged: _aiRetrying ? null : _onAIToggle,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButton() {
    final l10n = AppLocalizations.of(context);
    return ElevatedButton(
      onPressed: () {
        context.read<HomeBloc>().add(ResetResultsOnly());
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      child: Text(
        l10n.scanAnother, // ✅
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),
    );
  }
}
