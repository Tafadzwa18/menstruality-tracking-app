import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import 'settings_screen.dart';
import '../doctors/doctor_list.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 24),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(appState),
            const SizedBox(height: 32),
            const Text('My Baselines', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildBaselinesCard(appState),
            const SizedBox(height: 32),
            const Text('Preferences', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPreferencesList(context, appState),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(AppState appState) {
    return Row(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryPink.withOpacity(0.2),
            border: Border.all(color: AppTheme.primaryPink, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.person, size: 40, color: AppTheme.primaryPink),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.userName,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              appState.userEmail,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBaselinesCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildBaselineRow(Icons.calendar_month, 'Average Cycle Length', '${appState.cycleLength} days'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.borderSubtle, height: 1),
          ),
          _buildBaselineRow(Icons.water_drop, 'Average Period', '${appState.periodLength} days'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.borderSubtle, height: 1),
          ),
          _buildBaselineRow(Icons.battery_charging_full, 'Peak Energy Phase', 'Ovulatory'),
        ],
      ),
    );
  }

  Widget _buildBaselineRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryPink, size: 18),
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPreferencesList(BuildContext context, AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildListTile(context, Icons.notifications_none, 'Push Notifications', trailing: Switch(
            value: appState.notificationsEnabled, 
            onChanged: (v) => context.read<AppState>().toggleNotifications(v),
            activeColor: AppTheme.primaryPink,
          )),
          _buildDivider(),
          _buildListTile(context, Icons.dark_mode_outlined, 'Dark Mode', trailing: Switch(
            value: appState.darkModeEnabled, 
            onChanged: (v) {
              context.read<AppState>().toggleDarkMode(v);
              _showComingSoon(context, "Light Mode themes");
            },
            activeColor: AppTheme.primaryPink,
          )),
          _buildDivider(),
          _buildListTile(context, Icons.medical_information_outlined, 'My Care Team', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorList()));
          }),
          _buildDivider(),
          _buildListTile(context, Icons.help_outline, 'Help & Support', onTap: () => _showComingSoon(context, "Support")),
        ],
      ),
    );
  }
  
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: AppTheme.borderSubtle, height: 1),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: AppTheme.textMuted),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}
