import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ShareEmailScreen extends StatefulWidget {
  const ShareEmailScreen({Key? key}) : super(key: key);

  @override
  State<ShareEmailScreen> createState() => _ShareEmailScreenState();
}

class _ShareEmailScreenState extends State<ShareEmailScreen> {
  final _emailController = TextEditingController(text: 'sarah@example.com');
  final _subjectController = TextEditingController(text: 'Health Report - Jane Doe (Sep-Nov)');
  final _messageController = TextEditingController(
    text: 'Dear Dr. Jenkins,\n\nPlease find attached my health and menstruality report for the last 3 cycles for our upcoming appointment.\n\nBest regards,\nJane Doe',
  );
  bool _encryptReport = true;

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    decoration: BoxDecoration(color: AppTheme.primaryPink.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryPink),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Jane_Doe_Report_Sep-Nov.pdf', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
