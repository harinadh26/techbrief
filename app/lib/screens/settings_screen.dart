/// settings_screen.dart - App Preferences & About TechBrief

import 'package:flutter/material.dart';
import '../providers/news_provider.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  final NewsProvider provider;

  const SettingsScreen({Key? key, required this.provider}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.provider.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _saveUrl() {
    final text = _urlController.text.trim();
    if (text.isNotEmpty) {
      widget.provider.updateBaseUrl(text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backend URL updated to: $text')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = widget.provider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section 1: Appearance
          _buildSectionHeader('APPEARANCE', isDark),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primaryBlue,
              ),
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text(
                isDark ? 'Dark navy theme active' : 'Clean light theme active',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              value: provider.isDarkMode,
              activeColor: AppColors.primaryBlue,
              onChanged: (_) => provider.toggleTheme(),
            ),
          ),

          const SizedBox(height: 24),

          // Section 2: Backend Configuration
          _buildSectionHeader('BACKEND SERVER CONFIGURATION', isDark),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.dns_rounded, size: 20, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      const Text(
                        'API Base URL',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Point to your local FastAPI backend instance or cloud deployment.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'http://10.167.171.225:8000',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue),
                        onPressed: _saveUrl,
                        tooltip: 'Apply URL',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Preset pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.wifi, size: 14),
                        label: const Text('Phone Wi-Fi (10.167.171.225)', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          _urlController.text = 'http://10.167.171.225:8000';
                          _saveUrl();
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.computer, size: 14),
                        label: const Text('Chrome/PC (localhost)', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          _urlController.text = 'http://localhost:8000';
                          _saveUrl();
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.phone_android, size: 14),
                        label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          _urlController.text = 'http://10.0.2.2:8000';
                          _saveUrl();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Test Connection Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: provider.isTestingConnection
                          ? null
                          : () => provider.testConnection(_urlController.text),
                      icon: provider.isTestingConnection
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.network_check_rounded, size: 18),
                      label: Text(
                        provider.isTestingConnection ? 'Testing...' : 'Test Connection',
                      ),
                    ),
                  ),
                  if (provider.lastHealthCheck != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: provider.lastHealthCheck!['status'] == 'healthy'
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            provider.lastHealthCheck!['status'] == 'healthy'
                                ? Icons.check_circle_rounded
                                : Icons.error_outline_rounded,
                            size: 18,
                            color: provider.lastHealthCheck!['status'] == 'healthy'
                                ? const Color(0xFF10B981)
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.lastHealthCheck!['status'] == 'healthy'
                                  ? 'Connected! Service: ${provider.lastHealthCheck!['service']} (Uptime: ${provider.lastHealthCheck!['uptime_seconds']}s)'
                                  : 'Connection Failed: ${provider.lastHealthCheck!['error'] ?? 'Unreachable'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: provider.lastHealthCheck!['status'] == 'healthy'
                                    ? const Color(0xFF047857)
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section 3: About TechBrief
          _buildSectionHeader('ABOUT TECHBRIEF', isDark),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.aiBadgePurple],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.newspaper_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'v${AppConstants.appVersion}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'TechBrief is an AI-powered technology news application that collects the latest tech articles from TechCrunch, The Verge, and VentureBeat, and condenses them into two short, factual, and easy-to-understand sentences using Claude AI.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildAboutRow(
                    'AI Model',
                    'Anthropic Claude Haiku',
                    Icons.psychology_outlined,
                    isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildAboutRow(
                    'Backend',
                    'FastAPI + Uvicorn + Feedparser',
                    Icons.memory_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildAboutRow(
                    'Frontend',
                    'Flutter + Dart (Material 3)',
                    Icons.phone_android_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildAboutRow(
                    'Cache TTL',
                    '30 Minutes (Thread-safe)',
                    Icons.timer_outlined,
                    isDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }

  Widget _buildAboutRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextNavy,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
