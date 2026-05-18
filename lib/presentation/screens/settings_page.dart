import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paddy_scan/core/constants/app_colors.dart' as palette;
import 'package:paddy_scan/core/constants/disease_info.dart';
import 'package:paddy_scan/core/constants/theme_colors.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';
import 'package:paddy_scan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  static const String _hostedUrl =
      'https://HAFALI-paddyscan-backend.hf.space';

  bool _darkModeEnabled = true;
  bool _urduEnabled = false;
  bool _aiDiagnosisEnabled = true;
  String _selectedModel = 'deepseek/deepseek-chat:free';
  bool _isCheckingServer = false;
  String _serverStatus = ''; // '', 'online', 'offline'
  bool _useLocalServer = false;
  final TextEditingController _serverIpController =
      TextEditingController(text: '192.168.100.101');
  SharedPreferences? _prefs;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const List<Map<String, String>> _freeModels = [
    {'label': 'DeepSeek Chat (Best Quality)', 'value': 'deepseek/deepseek-chat:free'},
    {'label': 'Llama 3.1 8B', 'value': 'meta-llama/llama-3.1-8b-instruct:free'},
    {'label': 'Mistral 7B', 'value': 'mistralai/mistral-7b-instruct:free'},
    {'label': 'Google Gemma 2 9B', 'value': 'google/gemma-2-9b-it:free'},
    {'label': 'Llama 3.2 3B (Fastest)', 'value': 'meta-llama/llama-3.2-3b-instruct:free'},
    {'label': 'Microsoft Phi-3 Mini', 'value': 'microsoft/phi-3-mini-128k-instruct:free'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadSettings();
  }

  @override
  void dispose() {
    _animController.dispose();
    _serverIpController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = _prefs!.getBool('dark_mode') ?? true;
      _urduEnabled = _prefs!.getBool('urdu_enabled') ?? false;
      _aiDiagnosisEnabled = _prefs!.getBool('ai_diagnosis') ?? true;
      _selectedModel = _prefs!.getString('ai_model') ?? 'deepseek/deepseek-chat:free';
      _useLocalServer = _prefs!.getBool('use_local_server') ?? false;
      _serverIpController.text =
          _prefs!.getString('server_ip') ?? '192.168.100.101';
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    (_prefs ?? await SharedPreferences.getInstance()).setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    (_prefs ?? await SharedPreferences.getInstance()).setString(key, value);
  }

  Future<void> _checkServerStatus() async {
    setState(() {
      _isCheckingServer = true;
      _serverStatus = '';
    });
    final checkUrl = _useLocalServer
        ? 'http://${_serverIpController.text.trim()}:7860/health'
        : '$_hostedUrl/health';
    try {
      final uri = Uri.parse(checkUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      setState(() {
        _serverStatus = response.statusCode == 200 ? 'online' : 'offline';
        _isCheckingServer = false;
      });
    } catch (e) {
      setState(() {
        _serverStatus = 'offline';
        _isCheckingServer = false;
      });
    }
  }

  Future<void> _clearCache(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.clearCacheTitle),
        content: Text(l10n.clearCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel,
                style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.clear,
                style: const TextStyle(color: palette.AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final urduEnabled = prefs.getBool('urdu_enabled');
      await prefs.clear();
      if (urduEnabled != null) await prefs.setBool('urdu_enabled', urduEnabled);

      setState(() {
        _aiDiagnosisEnabled = true;
        _selectedModel = 'deepseek/deepseek-chat:free';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cacheCleared),
            backgroundColor: palette.AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tc = ThemeColors.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ColoredBox(
      color: tc.background,
      child: SafeArea(
        top: false,
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(l10n),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 20 + bottomPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Server Status (hosted) ──────────────────────────
                      _buildSection(
                        tc: tc,
                        icon: Icons.cloud,
                        title: l10n.serverConnection,
                        color: palette.AppColors.primary,
                        children: [_buildHostedServerSection(tc)],
                      ),
                      const SizedBox(height: 16),

                      // ── Appearance ─────────────────────────────────────
                      _buildSection(
                        tc: tc,
                        icon: Icons.palette_outlined,
                        title: l10n.appearance,
                        color: const Color(0xFF6D4C41),
                        children: [
                          _buildSwitchTile(
                            tc: tc,
                            icon: _darkModeEnabled
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            iconColor: _darkModeEnabled
                                ? const Color(0xFF5C6BC0)
                                : const Color(0xFFFFA726),
                            title: _darkModeEnabled ? l10n.darkMode : l10n.lightMode,
                            subtitle: _darkModeEnabled
                                ? l10n.switchToLightTheme
                                : l10n.switchToDarkTheme,
                            value: _darkModeEnabled,
                            onChanged: (v) {
                              setState(() => _darkModeEnabled = v);
                              themeModeNotifier.value =
                                  v ? ThemeMode.dark : ThemeMode.light;
                              _saveBool('dark_mode', v);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Language ───────────────────────────────────────
                      _buildSection(
                        tc: tc,
                        icon: Icons.language,
                        title: l10n.language,
                        color: const Color(0xFF1565C0),
                        children: [
                          _buildSwitchTile(
                            tc: tc,
                            icon: Icons.translate,
                            iconColor: const Color(0xFF1565C0),
                            title: l10n.urduInterface,
                            subtitle: l10n.urduSubtitle,
                            value: _urduEnabled,
                            onChanged: (v) {
                              setState(() => _urduEnabled = v);
                              localeNotifier.value =
                                  v ? const Locale('ur') : const Locale('en');
                              _saveBool('urdu_enabled', v);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── AI Diagnosis ───────────────────────────────────
                      _buildSection(
                        tc: tc,
                        icon: Icons.auto_awesome,
                        title: l10n.aiDiagnosis,
                        color: const Color(0xFF6A1B9A),
                        children: [
                          _buildSwitchTile(
                            tc: tc,
                            icon: Icons.psychology,
                            iconColor: const Color(0xFF6A1B9A),
                            title: l10n.enableAI,
                            subtitle: l10n.enableAISubtitle,
                            value: _aiDiagnosisEnabled,
                            onChanged: (v) {
                              setState(() => _aiDiagnosisEnabled = v);
                              _saveBool('ai_diagnosis', v);
                            },
                          ),
                          if (_aiDiagnosisEnabled) ...[
                            _buildDivider(tc),
                            _buildModelSelector(l10n, tc),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Storage ────────────────────────────────────────
                      _buildSection(
                        tc: tc,
                        icon: Icons.storage,
                        title: l10n.storage,
                        color: palette.AppColors.warning,
                        children: [
                          _buildActionTile(
                            tc: tc,
                            icon: Icons.cleaning_services,
                            iconColor: palette.AppColors.warning,
                            title: l10n.clearCache,
                            subtitle: l10n.clearCacheSubtitle,
                            onTap: () => _clearCache(l10n),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── About ──────────────────────────────────────────
                      _buildSection(
                        tc: tc,
                        icon: Icons.info_outline,
                        title: l10n.about,
                        color: tc.textSecondary,
                        children: [
                          _buildInfoTile(tc, l10n.appVersion, '1.0.0'),
                          _buildDivider(tc),
                          _buildInfoTile(tc, l10n.model, 'YOLOv11 + CNN'),
                          _buildDivider(tc),
                          _buildInfoTile(tc, l10n.detectableDiseases, '5 types'),
                          _buildDivider(tc),
                          _buildActionTile(
                            tc: tc,
                            icon: Icons.menu_book,
                            iconColor: palette.AppColors.primary,
                            title: l10n.diseaseGlossary,
                            subtitle: l10n.diseaseGlossarySubtitle,
                            onTap: () => _showDiseaseGlossary(l10n, tc),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Server Status Widget ─────────────────────────────────────────────────
  Widget _buildHostedServerSection(ThemeColors tc) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (_isCheckingServer) {
      statusColor = Colors.orange;
      statusIcon = Icons.sync;
      statusText = 'Checking...';
    } else if (_serverStatus == 'online') {
      statusColor = palette.AppColors.primary;
      statusIcon = Icons.check_circle;
      statusText = 'Online';
    } else if (_serverStatus == 'offline') {
      statusColor = palette.AppColors.error;
      statusIcon = Icons.error;
      statusText = 'Offline';
    } else {
      statusColor = tc.textSecondary;
      statusIcon = Icons.cloud_outlined;
      statusText = 'Tap to check';
    }

    final displayUrl = _useLocalServer
        ? 'http://${_serverIpController.text.trim()}:7860'
        : _hostedUrl.replaceFirst('https://', '');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Local / Hosted toggle ────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (_useLocalServer
                          ? Colors.orange
                          : palette.AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _useLocalServer ? Icons.computer : Icons.cloud_done,
                  color: _useLocalServer
                      ? Colors.orange
                      : palette.AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _useLocalServer ? 'Local Server' : 'PaddyScan Cloud',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: tc.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _useLocalServer
                          ? 'Your local machine · port 7860'
                          : 'hf.space · Hugging Face',
                      style: TextStyle(fontSize: 12, color: tc.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _useLocalServer,
                onChanged: (v) {
                  setState(() {
                    _useLocalServer = v;
                    _serverStatus = '';
                  });
                  _saveBool('use_local_server', v);
                },
                activeTrackColor: Colors.orange.withValues(alpha: 0.4),
                activeThumbColor: Colors.orange,
              ),
            ],
          ),

          // ── IP field (only when local is active) ─────────────────────────
          if (_useLocalServer) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _serverIpController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 14, color: tc.textPrimary),
              decoration: InputDecoration(
                labelText: 'Server IP address',
                labelStyle: TextStyle(color: tc.textSecondary, fontSize: 13),
                prefixIcon:
                    Icon(Icons.lan_outlined, color: Colors.orange, size: 20),
                suffixText: ':7860',
                suffixStyle:
                    TextStyle(color: tc.textSecondary, fontSize: 13),
                filled: true,
                fillColor: tc.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.orange, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
              ),
              onChanged: (v) {
                _saveString('server_ip', v.trim());
                setState(() => _serverStatus = '');
              },
            ),
          ],

          const SizedBox(height: 12),

          // ── Active URL display ───────────────────────────────────────────
          InkWell(
            onTap: _isCheckingServer ? null : _checkServerStatus,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: tc.inputFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 14, color: tc.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayUrl,
                      style: TextStyle(
                        fontSize: 12,
                        color: tc.textSecondary,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isCheckingServer
                            ? SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: statusColor,
                                ),
                              )
                            : Icon(statusIcon,
                                size: 10, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Check button ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isCheckingServer ? null : _checkServerStatus,
              icon: const Icon(Icons.wifi_find, size: 18),
              label: const Text('Check Server Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _useLocalServer
                    ? Colors.orange
                    : palette.AppColors.primary,
                side: BorderSide(
                    color: _useLocalServer
                        ? Colors.orange
                        : palette.AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: palette.AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
              child: Icon(Icons.settings, size: 160, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required ThemeColors tc,
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: tc.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildModelSelector(AppLocalizations l10n, ThemeColors tc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy, color: Color(0xFF6A1B9A), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.aiModel,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: tc.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.aiModelSubtitle,
            style: TextStyle(fontSize: 12, color: tc.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: tc.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tc.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _freeModels.any((m) => m['value'] == _selectedModel)
                    ? _selectedModel
                    : _freeModels.first['value'],
                isExpanded: true,
                dropdownColor: tc.card,
                icon: const Icon(Icons.expand_more,
                    color: palette.AppColors.primary),
                items: _freeModels.map((model) {
                  return DropdownMenuItem(
                    value: model['value'],
                    child: Text(model['label']!,
                        style:
                            TextStyle(fontSize: 14, color: tc.textPrimary)),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() => _selectedModel = v!);
                  _saveString('ai_model', v!);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required ThemeColors tc,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: tc.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 12, color: tc.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor:
                palette.AppColors.primary.withValues(alpha: 0.4),
            activeThumbColor: palette.AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required ThemeColors tc,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: tc.textPrimary)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: tc.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: tc.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(ThemeColors tc, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color: tc.textPrimary,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  color: tc.textSecondary,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeColors tc) {
    return Divider(height: 1, thickness: 1, color: tc.divider, indent: 16);
  }

  void _showDiseaseGlossary(AppLocalizations l10n, ThemeColors tc) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final diseases = [
      {'name': 'Bacterial Leaf Blight', 'nameUrdu': 'بیکٹیریل پتی جھلساؤ', 'icon': '🦠'},
      {'name': 'Brown Spot',            'nameUrdu': 'بھورے دھبے',           'icon': '🟤'},
      {'name': 'Leaf Blast',            'nameUrdu': 'پتی جھلس',             'icon': '💨'},
      {'name': 'Leaf Scald',            'nameUrdu': 'پتی جھلساؤ',           'icon': '🔥'},
      {'name': 'Healthy',               'nameUrdu': 'صحت مند',              'icon': '✅'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: tc.cardElevated,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: tc.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                l10n.detectableDiseasesList,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: diseases.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: tc.divider),
                itemBuilder: (_, i) {
                  final displayName = isUrdu
                      ? diseases[i]['nameUrdu']!
                      : diseases[i]['name']!;
                  return ListTile(
                    leading: Text(diseases[i]['icon']!,
                        style: const TextStyle(fontSize: 24)),
                    title: Text(displayName,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: tc.textPrimary)),
                    trailing:
                        Icon(Icons.chevron_right, color: tc.textSecondary),
                    onTap: () => _showDiseaseDetail(
                        diseases[i]['name']!, diseases[i]['icon']!, tc,
                        displayName: displayName,
                        lang: isUrdu ? 'ur' : 'en'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiseaseDetail(String name, String icon, ThemeColors tc,
      {String lang = 'en', String? displayName}) {
    final definition = DiseaseInfo.getDefinition(name, lang: lang);
    final title = displayName ?? name;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: tc.cardElevated,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tc.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: tc.divider),
            const SizedBox(height: 12),
            Text(
              definition,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: tc.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
