import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../export/export_config.dart';
import '../onboarding/onboarding_screen.dart';
import '../doctors/doctor_list.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is our priority. Your menstuality data is stored locally on your device and encrypted when synced to your private Supabase account. We do not sell or share your personal health information with third parties.\n\nYou have full control over your data and can delete your account at any time.',
            style: TextStyle(color: AppTheme.textLight, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.primaryPink)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Delete Account', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete your account? This action is permanent and will remove all your cycle logs and data from our servers.',
          style: TextStyle(color: AppTheme.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await context.read<AppState>().deleteAccount();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title, int currentValue, ValueChanged<int> onSave) {
    final controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text('Edit $title', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderSubtle)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryPink)),
              hintText: 'Enter $title',
              hintStyle: const TextStyle(color: AppTheme.textMuted),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink),
              onPressed: () {
                final newValue = int.tryParse(controller.text);
                if (newValue != null && newValue > 0) {
                  onSave(newValue);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('PREFERENCES'),
            const SizedBox(height: 16),
            _buildSettingsBlock(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  value: appState.notificationsEnabled,
                  onChanged: (val) => context.read<AppState>().toggleNotifications(val),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  value: appState.darkModeEnabled,
                  onChanged: (val) {
                    context.read<AppState>().toggleDarkMode(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('CYCLE DETAILS'),
            const SizedBox(height: 16),
            _buildSettingsBlock(
              children: [
                _buildActionTile(
                  icon: Icons.calendar_month,
                  title: 'Cycle Length',
                  trailingText: '${appState.cycleLength} days',
                  onTap: () {
                    _showEditDialog(context, 'Cycle Length', appState.cycleLength, (val) {
                      context.read<AppState>().updateCycleLength(val);
                    });
                  },
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.water_drop_outlined,
                  title: 'Period Length',
                  trailingText: '${appState.periodLength} days',
                  onTap: () {
                    _showEditDialog(context, 'Period Length', appState.periodLength, (val) {
                      context.read<AppState>().updatePeriodLength(val);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('DATA & PRIVACY'),
            const SizedBox(height: 16),
            _buildSettingsBlock(
              children: [
                _buildActionTile(
                  icon: Icons.file_download_outlined,
                  title: 'Export Health Report',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExportConfig())),
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.security,
                  title: 'Privacy Policy',
                  onTap: () => _showPrivacyPolicy(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('ACCOUNT'),
            const SizedBox(height: 16),
            _buildSettingsBlock(
              children: [
                _buildActionTile(
                  icon: Icons.logout,
                  title: 'Log Out',
                  titleColor: Colors.white,
                  onTap: () async {
                    await context.read<AppState>().logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                          (route) => false);
                    }
                  },
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  titleColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  hideArrow: true,
                  onTap: () => _showDeleteAccountConfirmation(context),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsBlock({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: AppTheme.textMuted),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryPink,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? trailingText,
    Color? titleColor,
    Color? iconColor,
    bool hideArrow = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: iconColor ?? AppTheme.textMuted),
      title: Text(title, style: TextStyle(color: titleColor ?? Colors.white, fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
             Text(trailingText, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          if (!hideArrow)
             ...[
               if (trailingText != null) const SizedBox(width: 8),
               const Icon(Icons.chevron_right, color: AppTheme.textMuted),
             ]
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: AppTheme.borderSubtle, height: 1),
    );
  }
}
