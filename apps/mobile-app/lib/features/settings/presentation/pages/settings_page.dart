import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/industrial_theme.dart';
import '../../../../core/components/industrial_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('SYSTEM PREFS', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('INTERFACE'),
          IndustrialCard(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                _buildSettingTile('THEME_MODE', 'Select the primary color scheme', 'INDUSTRIAL_DARK'),
                const Divider(color: AppColors.border, height: 1),
                _buildSettingTile('DATA_REFRESH', 'How often to poll the backend', 'REALTIME (WS)'),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildSectionTitle('DANGER_ZONE', isDanger: true),
          IndustrialCard(
            padding: const EdgeInsets.all(0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: const Text('TERMINATE_SESSION', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              subtitle: const Text('End current authentication session', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  elevation: 0,
                ),
                onPressed: _handleLogout,
                child: const Text('LOGOUT', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: isDanger ? Colors.redAccent : AppColors.accent,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      trailing: Text(value, style: const TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
    );
  }
}
