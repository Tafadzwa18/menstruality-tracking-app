import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/models.dart';

class ShareEmailScreen extends StatefulWidget {
  const ShareEmailScreen({Key? key}) : super(key: key);

  @override
  State<ShareEmailScreen> createState() => _ShareEmailScreenState();
}

class _ShareEmailScreenState extends State<ShareEmailScreen> {
  late TextEditingController _emailController;
  late TextEditingController _subjectController;
  late TextEditingController _messageController;
  bool _encryptReport = true;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _emailController = TextEditingController(text: 'doctor@care.com');
    _subjectController = TextEditingController(text: 'Health Report - ${appState.userName}');
    _messageController = TextEditingController(
      text: 'Dear Doctor,\n\nPlease find attached my health and menstruality report generated from my tracking app.\n\nBest regards,\n${appState.userName}',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Share Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.primaryPink),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report Sent Successfully!')));
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('To', _emailController),
            const Divider(color: AppTheme.borderSubtle, height: 32),
            _buildTextField('Subject', _subjectController),
            const Divider(color: AppTheme.borderSubtle, height: 32),
            TextField(
              controller: _messageController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 32),
            // Attachment Mock
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.primaryPink.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryPink),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${appState.userName.replaceAll(' ', '_')}_Health_Report.pdf', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('1.2 MB', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Encrypt with Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Switch(
                  value: _encryptReport,
                  onChanged: (val) => setState(() => _encryptReport = val),
                  activeColor: AppTheme.primaryPink,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold))),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
